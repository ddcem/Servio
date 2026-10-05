using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Exceptions;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.Base;

/// <summary>
/// Paged, filtered reads. Responses are built with an EF projection, so only the columns
/// a response needs are loaded (no image blobs in lists, no N+1 queries).
/// </summary>
public abstract class BaseReadService<TEntity, TResponse, TSearch>(ServioDbContext context)
    : IReadService<TResponse, TSearch>
    where TEntity : class, IEntity
    where TResponse : class
    where TSearch : BaseSearchObject
{
    protected ServioDbContext Context { get; } = context;

    /// <summary>Used in "was not found" messages, e.g. "Menu item".</summary>
    protected abstract string EntityName { get; }

    protected abstract Expression<Func<TEntity, TResponse>> Projection { get; }

    /// <summary>Projection for the details endpoint; can include data that lists do not need.</summary>
    protected virtual Expression<Func<TEntity, TResponse>> DetailsProjection => Projection;

    /// <summary>Records visible through this service, e.g. without soft-deleted ones.</summary>
    protected virtual IQueryable<TEntity> Query => Context.Set<TEntity>();

    protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, TSearch search) => query;

    protected virtual IQueryable<TEntity> ApplyOrdering(IQueryable<TEntity> query, TSearch search) =>
        query.OrderByDescending(x => x.Id);

    public virtual async Task<PagedResult<TResponse>> GetPagedAsync(TSearch search, CancellationToken cancellationToken = default)
    {
        var query = ApplyFilter(Query.AsNoTracking(), search);
        var totalCount = await query.CountAsync(cancellationToken);

        var items = await ApplyOrdering(query, search)
            .Skip((search.Page - 1) * search.PageSize)
            .Take(search.PageSize)
            .Select(Projection)
            .ToListAsync(cancellationToken);

        return new PagedResult<TResponse>
        {
            Items = items,
            TotalCount = totalCount,
            Page = search.Page,
            PageSize = search.PageSize
        };
    }

    public virtual async Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default) =>
        await Query.AsNoTracking()
            .Where(x => x.Id == id)
            .Select(DetailsProjection)
            .FirstOrDefaultAsync(cancellationToken)
        ?? throw NotFound();

    protected NotFoundException NotFound() => new($"{EntityName} was not found. It may have been deleted.");

    protected static string? Normalize(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    /// <summary>Pattern for a case-insensitive "contains" search with EF.Functions.ILike.</summary>
    protected static string ContainsPattern(string value) =>
        "%" + value.Trim().Replace("\\", "\\\\").Replace("%", "\\%").Replace("_", "\\_") + "%";
}
