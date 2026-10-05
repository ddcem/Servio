using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.API.Controllers.Base;

[ApiController]
[Authorize]
public abstract class BaseReadController<TResponse, TSearch>(IReadService<TResponse, TSearch> service) : ControllerBase
    where TSearch : BaseSearchObject
{
    [HttpGet]
    public virtual async Task<ActionResult<PagedResult<TResponse>>> GetPaged([FromQuery] TSearch search,
        CancellationToken cancellationToken) =>
        Ok(await service.GetPagedAsync(search, cancellationToken));

    [HttpGet("{id:int}")]
    public virtual async Task<ActionResult<TResponse>> GetById(int id, CancellationToken cancellationToken) =>
        Ok(await service.GetByIdAsync(id, cancellationToken));
}
