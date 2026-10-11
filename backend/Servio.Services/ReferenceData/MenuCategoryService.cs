using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.ReferenceData;

public interface IMenuCategoryService
    : ICrudService<MenuCategoryResponse, MenuCategorySearchObject, MenuCategoryUpsertRequest, MenuCategoryUpsertRequest>;

public class MenuCategoryService(ServioDbContext context)
    : BaseCrudService<MenuCategory, MenuCategoryResponse, MenuCategorySearchObject, MenuCategoryUpsertRequest, MenuCategoryUpsertRequest>(context),
        IMenuCategoryService
{
    protected override string EntityName => "Menu category";

    protected override Expression<Func<MenuCategory, MenuCategoryResponse>> Projection => x => new MenuCategoryResponse
    {
        Id = x.Id,
        Name = x.Name,
        CourseType = x.CourseType,
        PreparationStationId = x.PreparationStationId,
        PreparationStationName = x.PreparationStation.Name,
        SortOrder = x.SortOrder,
        MenuItemCount = x.MenuItems.Count
    };

    protected override IQueryable<MenuCategory> ApplyFilter(IQueryable<MenuCategory> query, MenuCategorySearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            query = query.Where(x => EF.Functions.ILike(x.Name, ContainsPattern(fts)));
        }

        if (search.PreparationStationId is { } stationId)
        {
            query = query.Where(x => x.PreparationStationId == stationId);
        }

        if (search.CourseType is { } courseType)
        {
            query = query.Where(x => x.CourseType == courseType);
        }

        return query;
    }

    protected override IQueryable<MenuCategory> ApplyOrdering(IQueryable<MenuCategory> query, MenuCategorySearchObject search) =>
        query.OrderBy(x => x.SortOrder).ThenBy(x => x.Name);

    protected override void MapInsert(MenuCategoryUpsertRequest request, MenuCategory entity) => Map(request, entity);
    protected override void MapUpdate(MenuCategoryUpsertRequest request, MenuCategory entity) => Map(request, entity);

    protected override Task BeforeInsertAsync(MenuCategoryUpsertRequest request, MenuCategory entity, CancellationToken cancellationToken) =>
        ValidateAsync(entity, cancellationToken);

    protected override Task BeforeUpdateAsync(MenuCategoryUpsertRequest request, MenuCategory entity, CancellationToken cancellationToken) =>
        ValidateAsync(entity, cancellationToken);

    protected override async Task BeforeDeleteAsync(MenuCategory entity, CancellationToken cancellationToken)
    {
        var itemCount = await Context.MenuItems.CountAsync(x => x.CategoryId == entity.Id, cancellationToken);
        if (itemCount > 0)
        {
            throw new BusinessException(
                "The category '{0}' has {1} menu item(s), including removed items kept for order history, and cannot be deleted.", entity.Name, itemCount);
        }
    }

    private static void Map(MenuCategoryUpsertRequest request, MenuCategory entity)
    {
        entity.Name = request.Name.Trim();
        entity.CourseType = request.CourseType!.Value;
        entity.PreparationStationId = request.PreparationStationId!.Value;
        entity.SortOrder = request.SortOrder;
    }

    private async Task ValidateAsync(MenuCategory entity, CancellationToken cancellationToken)
    {
        if (!await Context.PreparationStations.AnyAsync(x => x.Id == entity.PreparationStationId, cancellationToken))
        {
            throw new BusinessException("The selected preparation station does not exist.");
        }

        var name = entity.Name.ToLower();
        if (await Context.MenuCategories.AnyAsync(x => x.Id != entity.Id && x.Name.ToLower() == name, cancellationToken))
        {
            throw new BusinessException("A category named '{0}' already exists.", entity.Name);
        }
    }
}
