using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.Model.Constants;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.API.Controllers.Base;

/// <summary>
/// Every staff member can read; only the admin can create, change or delete.
/// </summary>
public abstract class BaseCrudController<TResponse, TSearch, TInsert, TUpdate>(
    ICrudService<TResponse, TSearch, TInsert, TUpdate> service)
    : BaseReadController<TResponse, TSearch>(service)
    where TSearch : BaseSearchObject
{
    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    public virtual async Task<ActionResult<TResponse>> Insert(TInsert request, CancellationToken cancellationToken) =>
        Ok(await service.InsertAsync(request, cancellationToken));

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public virtual async Task<ActionResult<TResponse>> Update(int id, TUpdate request, CancellationToken cancellationToken) =>
        Ok(await service.UpdateAsync(id, request, cancellationToken));

    [HttpDelete("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public virtual async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        await service.DeleteAsync(id, cancellationToken);
        return NoContent();
    }
}
