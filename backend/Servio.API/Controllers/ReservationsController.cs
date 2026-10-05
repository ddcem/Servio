using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Reservations;

namespace Servio.API.Controllers;

/// <summary>
/// Reservations are managed by the admin; waiters can see them. They are never deleted, only cancelled.
/// </summary>
[Route("api/reservations")]
public class ReservationsController(IReservationService service)
    : BaseReadController<ReservationResponse, ReservationSearchObject>(service)
{
    [HttpPost]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<ReservationResponse>> Insert(ReservationUpsertRequest request, CancellationToken cancellationToken) =>
        Ok(await service.InsertAsync(request, cancellationToken));

    [HttpPut("{id:int}")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<ReservationResponse>> Update(int id, ReservationUpsertRequest request, CancellationToken cancellationToken) =>
        Ok(await service.UpdateAsync(id, request, cancellationToken));

    [HttpPost("{id:int}/confirm")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<ReservationResponse>> Confirm(int id, CancellationToken cancellationToken) =>
        Ok(await service.ConfirmAsync(id, cancellationToken));

    [HttpPost("{id:int}/complete")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<ReservationResponse>> Complete(int id, CancellationToken cancellationToken) =>
        Ok(await service.CompleteAsync(id, cancellationToken));

    [HttpPost("{id:int}/no-show")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<ReservationResponse>> MarkNoShow(int id, CancellationToken cancellationToken) =>
        Ok(await service.MarkNoShowAsync(id, cancellationToken));

    [HttpPost("{id:int}/cancel")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<ReservationResponse>> Cancel(int id, ReasonRequest request, CancellationToken cancellationToken) =>
        Ok(await service.CancelAsync(id, request, cancellationToken));
}
