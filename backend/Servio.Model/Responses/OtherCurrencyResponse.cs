namespace Servio.Model.Responses;

/// <summary>
/// Paid orders of the report period that were charged in a currency other than the restaurant's current one.
/// Reports never add different currencies together, so these orders are only counted here.
/// </summary>
public class OtherCurrencyResponse
{
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencySymbol { get; set; } = string.Empty;
    public int OrderCount { get; set; }
    public decimal Revenue { get; set; }
}
