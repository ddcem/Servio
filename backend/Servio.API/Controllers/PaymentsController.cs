using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Payments;

namespace Servio.API.Controllers;

/// <summary>
/// Waiters take payments; refunds are issued by the admin.
/// </summary>
[Route("api/payments")]
[Authorize(Roles = Roles.Admin + "," + Roles.Waiter)]
public class PaymentsController(IPaymentService service) : BaseReadController<PaymentResponse, PaymentSearchObject>(service)
{
    [HttpPost("cash")]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<PaymentResponse>> PayCash(CashPaymentRequest request, CancellationToken cancellationToken) =>
        Ok(await service.PayCashAsync(request, cancellationToken));

    [HttpPost("paypal")]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<PayPalCheckoutResponse>> StartPayPal(PayPalPaymentRequest request, CancellationToken cancellationToken) =>
        Ok(await service.StartPayPalAsync(request, cancellationToken));

    [HttpPost("{id:int}/paypal/capture")]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<PaymentResponse>> CapturePayPal(int id, CancellationToken cancellationToken) =>
        Ok(await service.CapturePayPalAsync(id, cancellationToken));

    [HttpPost("{id:int}/cancel")]
    [Authorize(Roles = Roles.Waiter)]
    public async Task<ActionResult<PaymentResponse>> Cancel(int id, CancellationToken cancellationToken) =>
        Ok(await service.CancelAsync(id, cancellationToken));

    [HttpPost("{id:int}/refunds")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<PaymentResponse>> Refund(int id, RefundRequest request, CancellationToken cancellationToken) =>
        Ok(await service.RefundAsync(id, request, cancellationToken));
}
