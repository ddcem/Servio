using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.ReferenceData;

/// <summary>
/// Read-only reference data whose names are bound to constants in code (roles, preparation stations,
/// payment methods). Renaming or deleting them would break authorization and order routing,
/// so they are seeded and only listed.
/// </summary>
public class LookupService<TEntity>(ServioDbContext context)
    : BaseReadService<TEntity, LookupResponse, BaseSearchObject>(context)
    where TEntity : class, INamedEntity
{
    protected override string EntityName => typeof(TEntity).Name;

    protected override Expression<Func<TEntity, LookupResponse>> Projection =>
        x => new LookupResponse { Id = x.Id, Name = x.Name };

    protected override IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, BaseSearchObject search) =>
        Normalize(search.FTS) is { } fts ? query.Where(x => EF.Functions.ILike(x.Name, ContainsPattern(fts))) : query;

    protected override IQueryable<TEntity> ApplyOrdering(IQueryable<TEntity> query, BaseSearchObject search) =>
        query.OrderBy(x => x.Name);
}
