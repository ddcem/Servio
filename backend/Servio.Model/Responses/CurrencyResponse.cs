namespace Servio.Model.Responses;

public class CurrencyResponse
{
    public int Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Symbol { get; set; } = string.Empty;

    /// <summary>A currency used by the settings or by existing orders cannot be deleted.</summary>
    public bool IsInUse { get; set; }
}
