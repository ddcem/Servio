namespace Servio.Services.Payments.PayPal;

/// <summary>
/// Server-side PayPal Orders v2 API. Amounts are always decided by the server.
/// </summary>
public interface IPayPalClient
{
    Task<PayPalCheckout> CreateOrderAsync(string referenceId, string description, decimal amount, string currencyCode,
        CancellationToken cancellationToken = default);

    /// <summary>Captures an approved order. Safe to repeat: an already captured order returns its capture.</summary>
    Task<PayPalCapture> CaptureOrderAsync(string orderId, string requestId, CancellationToken cancellationToken = default);

    Task<PayPalRefund> RefundCaptureAsync(string captureId, decimal amount, string currencyCode, string note, string requestId,
        CancellationToken cancellationToken = default);
}
