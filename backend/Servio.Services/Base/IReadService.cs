using Servio.Model.Responses;
using Servio.Model.SearchObjects;

namespace Servio.Services.Base;

public interface IReadService<TResponse, in TSearch> where TSearch : BaseSearchObject
{
    Task<PagedResult<TResponse>> GetPagedAsync(TSearch search, CancellationToken cancellationToken = default);
    Task<TResponse> GetByIdAsync(int id, CancellationToken cancellationToken = default);
}
