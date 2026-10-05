using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Orders;

namespace Servio.API.Controllers;

/// <summary>
/// Kitchen and bar staff move their tickets forward; waiters serve or cancel them;
/// the admin only watches (no status changes).
/// </summary>
[Route("api/order-tickets")]
public class OrderTicketsController(IOrderTicketService service)
    : BaseReadController<OrderTicketResponse, OrderTicketSearchObject>(service)
{
    [HttpGet("station-summaries")]
    [Authorize(Roles = Roles.Stations)]
    public async Task<ActionResult<List<StationSummaryResponse>>> GetStationSummaries(CancellationToken cancellationToken) =>
        Ok(await service.GetStationSummariesAsync(cancellationToken));

    [HttpPost("{id:int}/start")]
    [Authorize(Roles = Roles.Kitchen + "," + Roles.Bar)]
    public async Task<ActionResult<OrderTicketResponse>> Start(int id, CancellationToken cancellationToken) =>
        Ok(await service.StartAsync(id, cancellationToken));

    [HttpPost("{id:int}/ready")]
    [Authorize(Roles = Roles.Kitchen + "," + Roles.Bar)]
    public async Task<ActionResult<OrderTicketResponse>> MarkReady(int id, CancellationToken cancellationToken) =>
        Ok(await service.MarkReadyAsync(id, cancellationToken));

    [HttpPost("{id:int}/serve")]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<OrderTicketResponse>> Serve(int id, CancellationToken cancellationToken) =>
        Ok(await service.ServeAsync(id, cancellationToken));

    [HttpPost("{id:int}/cancel")]
    [Authorize(Roles = Roles.Admin + "," + Roles.Waiter)]
    public async Task<ActionResult<OrderTicketResponse>> Cancel(int id, ReasonRequest request, CancellationToken cancellationToken) =>
        Ok(await service.CancelAsync(id, request, cancellationToken));
}
