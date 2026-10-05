using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class ReservationResponse
{
    public int Id { get; set; }
    public int TableId { get; set; }
    public int TableNumber { get; set; }
    public string GuestName { get; set; } = string.Empty;
    public string GuestPhone { get; set; } = string.Empty;
    public string? GuestEmail { get; set; }
    public int PartySize { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public ReservationStatus Status { get; set; }
    public string? Note { get; set; }
    public string CreatedByName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    /// <summary>Filled only on the details endpoint.</summary>
    public List<StatusHistoryResponse> History { get; set; } = [];
}
