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

public interface ITableAreaService
    : ICrudService<TableAreaResponse, BaseSearchObject, NameUpsertRequest, NameUpsertRequest>;

public class TableAreaService(ServioDbContext context)
    : BaseCrudService<TableArea, TableAreaResponse, BaseSearchObject, NameUpsertRequest, NameUpsertRequest>(context),
        ITableAreaService
{
    protected override string EntityName => "Table area";

    protected override Expression<Func<TableArea, TableAreaResponse>> Projection => x => new TableAreaResponse
    {
        Id = x.Id,
        Name = x.Name,
        TableCount = x.Tables.Count
    };

    protected override IQueryable<TableArea> ApplyFilter(IQueryable<TableArea> query, BaseSearchObject search) =>
        Normalize(search.FTS) is { } fts ? query.Where(x => EF.Functions.ILike(x.Name, ContainsPattern(fts))) : query;

    protected override void MapInsert(NameUpsertRequest request, TableArea entity) => entity.Name = request.Name.Trim();
    protected override void MapUpdate(NameUpsertRequest request, TableArea entity) => entity.Name = request.Name.Trim();

    protected override Task BeforeInsertAsync(NameUpsertRequest request, TableArea entity, CancellationToken cancellationToken) =>
        EnsureUniqueNameAsync(entity, cancellationToken);

    protected override Task BeforeUpdateAsync(NameUpsertRequest request, TableArea entity, CancellationToken cancellationToken) =>
        EnsureUniqueNameAsync(entity, cancellationToken);

    protected override async Task BeforeDeleteAsync(TableArea entity, CancellationToken cancellationToken)
    {
        var tableCount = await Context.RestaurantTables.CountAsync(x => x.AreaId == entity.Id, cancellationToken);
        if (tableCount > 0)
        {
            throw new BusinessException(
                "The area '{0}' still has {1} table(s). Move them to another area or delete them first.", entity.Name, tableCount);
        }
    }

    private async Task EnsureUniqueNameAsync(TableArea entity, CancellationToken cancellationToken)
    {
        var name = entity.Name.ToLower();
        if (await Context.TableAreas.AnyAsync(x => x.Id != entity.Id && x.Name.ToLower() == name, cancellationToken))
        {
            throw new BusinessException("An area named '{0}' already exists.", entity.Name);
        }
    }
}
