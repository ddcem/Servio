using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Images;
using Servio.Services.Notifications;
using Servio.Services.Recommendations;

namespace Servio.Services.Menu;

/// <summary>
/// Menu items are soft-deleted: past orders keep referencing them, but they disappear from the menu.
/// </summary>
public class MenuItemService(
    ServioDbContext context,
    ICurrentUserService currentUser,
    INotificationDispatcher dispatcher,
    IRecommendationService recommendationService)
    : BaseCrudService<MenuItem, MenuItemResponse, MenuItemSearchObject, MenuItemUpsertRequest, MenuItemUpsertRequest>(context),
        IMenuItemService
{
    protected override string EntityName => "Menu item";

    protected override IQueryable<MenuItem> Query => Context.MenuItems.Where(x => !x.IsDeleted);

    protected override Expression<Func<MenuItem, MenuItemResponse>> Projection
    {
        get
        {
            var userId = currentUser.UserId;
            return x => new MenuItemResponse
            {
                Id = x.Id,
                Name = x.Name,
                Description = x.Description,
                Price = x.Price,
                CategoryId = x.CategoryId,
                CategoryName = x.Category.Name,
                CourseType = x.Category.CourseType,
                PreparationStationId = x.Category.PreparationStationId,
                PreparationStationName = x.Category.PreparationStation.Name,
                IsAvailableToday = x.IsAvailableToday,
                HasImage = x.Image != null,
                IsFavorite = x.FavoritedBy.Any(u => u.Id == userId),
                SoldByMeCount = Context.OrderItems
                    .Where(i => i.MenuItemId == x.Id && i.Order.WaiterId == userId
                                && i.Order.Status != OrderStatus.Cancelled && i.OrderTicket.Status != TicketStatus.Cancelled)
                    .Sum(i => (int?)i.Quantity) ?? 0,
                Tags = x.Tags.OrderBy(t => t.Name).Select(t => new LookupResponse { Id = t.Id, Name = t.Name }).ToList()
            };
        }
    }

    protected override IQueryable<MenuItem> ApplyFilter(IQueryable<MenuItem> query, MenuItemSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            var pattern = ContainsPattern(fts);
            query = query.Where(x => EF.Functions.ILike(x.Name, pattern)
                                     || (x.Description != null && EF.Functions.ILike(x.Description, pattern)));
        }

        if (search.CategoryId is { } categoryId)
        {
            query = query.Where(x => x.CategoryId == categoryId);
        }

        if (search.PreparationStationId is { } stationId)
        {
            query = query.Where(x => x.Category.PreparationStationId == stationId);
        }

        if (search.CourseType is { } courseType)
        {
            query = query.Where(x => x.Category.CourseType == courseType);
        }

        if (search.TagId is { } tagId)
        {
            query = query.Where(x => x.Tags.Any(t => t.Id == tagId));
        }

        if (search.IsAvailableToday is { } isAvailable)
        {
            query = query.Where(x => x.IsAvailableToday == isAvailable);
        }

        if (search.MinPrice is { } minPrice)
        {
            query = query.Where(x => x.Price >= minPrice);
        }

        if (search.MaxPrice is { } maxPrice)
        {
            query = query.Where(x => x.Price <= maxPrice);
        }

        if (search.FavoritesOnly)
        {
            var userId = currentUser.UserId;
            query = query.Where(x => x.FavoritedBy.Any(u => u.Id == userId));
        }

        return query;
    }

    protected override IQueryable<MenuItem> ApplyOrdering(IQueryable<MenuItem> query, MenuItemSearchObject search) =>
        search.NewestFirst
            ? query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id)
            : query.OrderBy(x => x.Category.SortOrder).ThenBy(x => x.Name);

    protected override async Task<MenuItem> LoadForUpdateAsync(int id, CancellationToken cancellationToken) =>
        await Query.Include(x => x.Tags).FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();

    protected override void MapInsert(MenuItemUpsertRequest request, MenuItem entity)
    {
        Map(request, entity);
        entity.CreatedAt = DateTime.UtcNow;
    }

    protected override void MapUpdate(MenuItemUpsertRequest request, MenuItem entity) => Map(request, entity);

    protected override Task BeforeInsertAsync(MenuItemUpsertRequest request, MenuItem entity, CancellationToken cancellationToken) =>
        ValidateAndSetTagsAsync(request, entity, cancellationToken);

    protected override Task BeforeUpdateAsync(MenuItemUpsertRequest request, MenuItem entity, CancellationToken cancellationToken) =>
        ValidateAndSetTagsAsync(request, entity, cancellationToken);

    protected override async Task BeforeDeleteAsync(MenuItem entity, CancellationToken cancellationToken)
    {
        // Favorites and tags are not needed once the item is off the menu; order history keeps the item itself.
        await Context.Entry(entity).Collection(x => x.FavoritedBy).LoadAsync(cancellationToken);
        entity.FavoritedBy.Clear();
        entity.Tags.Clear();
    }

    protected override void Remove(MenuItem entity)
    {
        entity.IsDeleted = true;
        entity.IsAvailableToday = false;
    }

    public override async Task<MenuItemResponse> InsertAsync(MenuItemUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var response = await base.InsertAsync(request, cancellationToken);
        await PublishMenuChangedAsync(cancellationToken);
        return response;
    }

    public override async Task<MenuItemResponse> UpdateAsync(int id, MenuItemUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var response = await base.UpdateAsync(id, request, cancellationToken);
        await PublishMenuChangedAsync(cancellationToken);
        return response;
    }

    public override async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        await base.DeleteAsync(id, cancellationToken);
        await PublishMenuChangedAsync(cancellationToken);
    }

    public async Task<MenuItemResponse> SetAvailabilityAsync(int id, MenuItemAvailabilityRequest request,
        CancellationToken cancellationToken = default)
    {
        var entity = await Query.FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();
        entity.IsAvailableToday = request.IsAvailableToday;
        await Context.SaveChangesAsync(cancellationToken);

        await PublishMenuChangedAsync(cancellationToken);
        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ImageFile> GetImageAsync(int id, CancellationToken cancellationToken = default)
    {
        // Removed items are still shown in order history, so their images stay readable.
        var image = await Context.MenuItems
            .Where(x => x.Id == id && x.Image != null)
            .Select(x => new { x.Image, x.ImageContentType })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new NotFoundException("This menu item has no image.");

        return new ImageFile(image.Image!, image.ImageContentType!);
    }

    public async Task SetImageAsync(int id, byte[] content, CancellationToken cancellationToken = default)
    {
        var image = ImageValidator.Validate(content);
        var entity = await Query.FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();

        entity.Image = image.Content;
        entity.ImageContentType = image.ContentType;
        await Context.SaveChangesAsync(cancellationToken);

        await PublishMenuChangedAsync(cancellationToken);
    }

    public async Task DeleteImageAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await Query.FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();

        entity.Image = null;
        entity.ImageContentType = null;
        await Context.SaveChangesAsync(cancellationToken);

        await PublishMenuChangedAsync(cancellationToken);
    }

    public async Task AddFavoriteAsync(int id, CancellationToken cancellationToken = default)
    {
        var user = await LoadUserWithFavoriteAsync(id, cancellationToken);
        if (user.FavoriteMenuItems.Count > 0)
        {
            return;
        }

        var item = await Query.FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();
        user.FavoriteMenuItems.Add(item);
        await Context.SaveChangesAsync(cancellationToken);
    }

    public async Task RemoveFavoriteAsync(int id, CancellationToken cancellationToken = default)
    {
        var user = await LoadUserWithFavoriteAsync(id, cancellationToken);
        if (user.FavoriteMenuItems.Count == 0)
        {
            return;
        }

        user.FavoriteMenuItems.Clear();
        await Context.SaveChangesAsync(cancellationToken);
    }

    /// <summary>Loads the current user with only the given item in the favorites collection (if it is a favorite).</summary>
    private async Task<User> LoadUserWithFavoriteAsync(int menuItemId, CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId;
        return await Context.Users
            .Include(x => x.FavoriteMenuItems.Where(m => m.Id == menuItemId))
            .FirstAsync(x => x.Id == userId, cancellationToken);
    }

    private static void Map(MenuItemUpsertRequest request, MenuItem entity)
    {
        entity.Name = request.Name.Trim();
        entity.Description = Normalize(request.Description);
        entity.Price = request.Price!.Value;
        entity.CategoryId = request.CategoryId!.Value;
        entity.IsAvailableToday = request.IsAvailableToday;
    }

    private async Task ValidateAndSetTagsAsync(MenuItemUpsertRequest request, MenuItem entity, CancellationToken cancellationToken)
    {
        if (!await Context.MenuCategories.AnyAsync(x => x.Id == entity.CategoryId, cancellationToken))
        {
            throw new BusinessException("The selected category does not exist.");
        }

        var name = entity.Name.ToLower();
        if (await Query.AnyAsync(x => x.Id != entity.Id && x.Name.ToLower() == name, cancellationToken))
        {
            throw new BusinessException($"A menu item named '{entity.Name}' already exists.");
        }

        var tagIds = request.TagIds.Distinct().ToList();
        var tags = await Context.ItemTags.Where(x => tagIds.Contains(x.Id)).ToListAsync(cancellationToken);
        if (tags.Count != tagIds.Count)
        {
            throw new BusinessException("Some of the selected tags no longer exist. Reload the form and try again.");
        }

        entity.Tags.Clear();
        foreach (var tag in tags)
        {
            entity.Tags.Add(tag);
        }
    }

    private Task PublishMenuChangedAsync(CancellationToken cancellationToken)
    {
        recommendationService.InvalidateMenu();
        dispatcher.Broadcast(RealtimeEvents.MenuChanged);
        return dispatcher.FlushAsync(cancellationToken);
    }
}
