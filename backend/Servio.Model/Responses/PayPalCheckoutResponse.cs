namespace Servio.Model.Responses;

/// <summary>
/// The app opens <see cref="ApprovalUrl"/> in an in-app browser; PayPal returns to the app's
/// deep link, and the app then asks the server to capture the payment.
/// </summary>
public class PayPalCheckoutResponse
{
    public int PaymentId { get; set; }
    public string PayPalOrderId { get; set; } = string.Empty;
    public string ApprovalUrl { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
}
