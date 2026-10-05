namespace Servio.Model.Responses;

/// <summary>
/// Read-only reference data (roles, preparation stations, payment methods) used to fill dropdowns.
/// </summary>
public class LookupResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
