using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Orders;

namespace Servio.API.Controllers;

[Route("api/orders")]
[Authorize(Roles = Roles.Admin + "," + Roles.Waiter)]
public class OrdersController(IOrderService service) : BaseReadController<OrderResponse, OrderSearchObject>(service)
{
    [HttpPost]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<OrderResponse>> Create(OrderCreateRequest request, CancellationToken cancellationToken) =>
        Ok(await service.CreateAsync(request, cancellationToken));

    [HttpPost("{id:int}/items")]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<OrderResponse>> AddItems(int id, OrderAddItemsRequest request, CancellationToken cancellationToken) =>
        Ok(await service.AddItemsAsync(id, request, cancellationToken));

    [HttpPost("{id:int}/cancel")]
    public async Task<ActionResult<OrderResponse>> Cancel(int id, ReasonRequest request, CancellationToken cancellationToken) =>
        Ok(await service.CancelAsync(id, request, cancellationToken));
}
