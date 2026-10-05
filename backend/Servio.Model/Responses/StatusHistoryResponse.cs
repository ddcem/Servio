namespace Servio.Model.Responses;

/// <summary>
/// One entry of an audit trail: who changed the status, when and why.
/// </summary>
public class StatusHistoryResponse
{
    public string? FromStatus { get; set; }
    public string ToStatus { get; set; } = string.Empty;
    public string ChangedByName { get; set; } = string.Empty;
    public string? Reason { get; set; }
    public DateTime ChangedAt { get; set; }
}
