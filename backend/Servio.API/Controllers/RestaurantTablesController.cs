using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Tables;

namespace Servio.API.Controllers;

[Route("api/tables")]
public class RestaurantTablesController(IRestaurantTableService service)
    : BaseCrudController<RestaurantTableResponse, RestaurantTableSearchObject, RestaurantTableUpsertRequest, RestaurantTableUpsertRequest>(service)
{
    /// <summary>Assigns tables to waiters for the current shift (waiterId null = any waiter).</summary>
    [HttpPut("assignments")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> Assign(TableAssignmentsRequest request, CancellationToken cancellationToken)
    {
        await service.AssignAsync(request, cancellationToken);
        return NoContent();
    }
}
