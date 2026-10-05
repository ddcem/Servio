namespace Servio.Services.Configuration;

public class PayPalOptions
{
    public string BaseUrl { get; set; } = string.Empty;
    public string ClientId { get; set; } = string.Empty;
    public string ClientSecret { get; set; } = string.Empty;

    /// <summary>Deep link PayPal sends the payer back to after approving, e.g. servio://paypal/return.</summary>
    public string ReturnUrl { get; set; } = string.Empty;
    public string CancelUrl { get; set; } = string.Empty;
}
