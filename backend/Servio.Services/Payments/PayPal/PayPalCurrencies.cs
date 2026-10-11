namespace Servio.Services.Payments.PayPal;

/// <summary>
/// Currencies PayPal accepts with two decimal places. BAM (KM) is not one of them, so PayPal is unavailable for it.
/// </summary>
public static class PayPalCurrencies
{
    public static readonly string[] Supported =
    [
        "AUD", "BRL", "CAD", "CHF", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "ILS", "MXN",
        "MYR", "NOK", "NZD", "PHP", "PLN", "SEK", "SGD", "THB", "USD"
    ];
}
