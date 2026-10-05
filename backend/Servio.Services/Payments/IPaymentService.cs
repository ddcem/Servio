using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Payments;

public interface IPaymentService : IReadService<PaymentResponse, PaymentSearchObject>
{
    /// <summary>Records a cash payment and closes the order.</summary>
    Task<PaymentResponse> PayCashAsync(CashPaymentRequest request, CancellationToken cancellationToken = default);

    /// <summary>Creates a PayPal order for the bill plus tip; the guest approves it in the app.</summary>
    Task<PayPalCheckoutResponse> StartPayPalAsync(PayPalPaymentRequest request, CancellationToken cancellationToken = default);

    /// <summary>Captures the approved PayPal order on the server and closes the order. Idempotent.</summary>
    Task<PaymentResponse> CapturePayPalAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>The guest cancelled in PayPal; the order stays open for another attempt.</summary>
    Task<PaymentResponse> CancelAsync(int id, CancellationToken cancellationToken = default);

    Task<PaymentResponse> RefundAsync(int id, RefundRequest request, CancellationToken cancellationToken = default);
}
