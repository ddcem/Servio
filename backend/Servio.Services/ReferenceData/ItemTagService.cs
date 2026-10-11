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

public interface IItemTagService
    : ICrudService<ItemTagResponse, BaseSearchObject, NameUpsertRequest, NameUpsertRequest>;

public class ItemTagService(ServioDbContext context)
    : BaseCrudService<ItemTag, ItemTagResponse, BaseSearchObject, NameUpsertRequest, NameUpsertRequest>(context),
        IItemTagService
{
    protected override string EntityName => "Tag";

    protected override Expression<Func<ItemTag, ItemTagResponse>> Projection => x => new ItemTagResponse
    {
        Id = x.Id,
        Name = x.Name,
        MenuItemCount = x.MenuItems.Count(m => !m.IsDeleted)
    };

    protected override IQueryable<ItemTag> ApplyFilter(IQueryable<ItemTag> query, BaseSearchObject search) =>
        Normalize(search.FTS) is { } fts ? query.Where(x => EF.Functions.ILike(x.Name, ContainsPattern(fts))) : query;

    protected override IQueryable<ItemTag> ApplyOrdering(IQueryable<ItemTag> query, BaseSearchObject search) =>
        query.OrderBy(x => x.Name);

    protected override void MapInsert(NameUpsertRequest request, ItemTag entity) => entity.Name = request.Name.Trim();
    protected override void MapUpdate(NameUpsertRequest request, ItemTag entity) => entity.Name = request.Name.Trim();

    protected override Task BeforeInsertAsync(NameUpsertRequest request, ItemTag entity, CancellationToken cancellationToken) =>
        EnsureUniqueNameAsync(entity, cancellationToken);

    protected override Task BeforeUpdateAsync(NameUpsertRequest request, ItemTag entity, CancellationToken cancellationToken) =>
        EnsureUniqueNameAsync(entity, cancellationToken);

    protected override async Task BeforeDeleteAsync(ItemTag entity, CancellationToken cancellationToken)
    {
        var itemCount = await Context.MenuItems.CountAsync(x => x.Tags.Any(t => t.Id == entity.Id), cancellationToken);
        if (itemCount > 0)
        {
            throw new BusinessException(
                "The tag '{0}' is used by {1} menu item(s). Remove it from those items first.", entity.Name, itemCount);
        }
    }

    private async Task EnsureUniqueNameAsync(ItemTag entity, CancellationToken cancellationToken)
    {
        var name = entity.Name.ToLower();
        if (await Context.ItemTags.AnyAsync(x => x.Id != entity.Id && x.Name.ToLower() == name, cancellationToken))
        {
            throw new BusinessException("A tag named '{0}' already exists.", entity.Name);
        }
    }
}
