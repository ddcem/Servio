namespace Servio.Model.Responses;

public class SettingsResponse
{
    public string RestaurantName { get; set; } = string.Empty;
    public int CurrencyId { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencySymbol { get; set; } = string.Empty;
    public decimal TaxRate { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string? UpdatedByName { get; set; }
}
