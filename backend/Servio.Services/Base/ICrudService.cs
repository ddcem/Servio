using Servio.Model.SearchObjects;

namespace Servio.Services.Base;

public interface ICrudService<TResponse, in TSearch, in TInsert, in TUpdate> : IReadService<TResponse, TSearch>
    where TSearch : BaseSearchObject
{
    Task<TResponse> InsertAsync(TInsert request, CancellationToken cancellationToken = default);
    Task<TResponse> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default);
    Task DeleteAsync(int id, CancellationToken cancellationToken = default);
}
