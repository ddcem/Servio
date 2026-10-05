using Microsoft.EntityFrameworkCore;
using Servio.Model.SearchObjects;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.Base;

/// <summary>
/// Insert, update and delete on top of <see cref="BaseReadService{TEntity,TResponse,TSearch}"/>.
/// Derived services map requests and put their business rules in the Before* hooks.
/// </summary>
public abstract class BaseCrudService<TEntity, TResponse, TSearch, TInsert, TUpdate>(ServioDbContext context)
    : BaseReadService<TEntity, TResponse, TSearch>(context), ICrudService<TResponse, TSearch, TInsert, TUpdate>
    where TEntity : class, IEntity, new()
    where TResponse : class
    where TSearch : BaseSearchObject
{
    protected abstract void MapInsert(TInsert request, TEntity entity);
    protected abstract void MapUpdate(TUpdate request, TEntity entity);

    protected virtual Task BeforeInsertAsync(TInsert request, TEntity entity, CancellationToken cancellationToken) =>
        Task.CompletedTask;

    protected virtual Task BeforeUpdateAsync(TUpdate request, TEntity entity, CancellationToken cancellationToken) =>
        Task.CompletedTask;

    /// <summary>Throw a BusinessException with a clear reason when the record is still used elsewhere.</summary>
    protected virtual Task BeforeDeleteAsync(TEntity entity, CancellationToken cancellationToken) =>
        Task.CompletedTask;

    /// <summary>Loads the tracked entity for update/delete; override to include navigations.</summary>
    protected virtual async Task<TEntity> LoadForUpdateAsync(int id, CancellationToken cancellationToken) =>
        await Query.FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();

    /// <summary>Hard delete by default; soft-deleting services override this.</summary>
    protected virtual void Remove(TEntity entity) => Context.Remove(entity);

    public virtual async Task<TResponse> InsertAsync(TInsert request, CancellationToken cancellationToken = default)
    {
        var entity = new TEntity();
        MapInsert(request, entity);
        await BeforeInsertAsync(request, entity, cancellationToken);

        Context.Add(entity);
        await Context.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken);
    }

    public virtual async Task<TResponse> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default)
    {
        var entity = await LoadForUpdateAsync(id, cancellationToken);
        MapUpdate(request, entity);
        await BeforeUpdateAsync(request, entity, cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);

        return await GetByIdAsync(entity.Id, cancellationToken);
    }

    public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await LoadForUpdateAsync(id, cancellationToken);
        await BeforeDeleteAsync(entity, cancellationToken);

        Remove(entity);
        await Context.SaveChangesAsync(cancellationToken);
    }
}
