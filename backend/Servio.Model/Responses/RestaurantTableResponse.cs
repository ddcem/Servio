using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class RestaurantTableResponse
{
    public int Id { get; set; }
    public int Number { get; set; }
    public int Capacity { get; set; }
    public int AreaId { get; set; }
    public string AreaName { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public TableStatus Status { get; set; }

    public int? CurrentOrderId { get; set; }
    public decimal? CurrentOrderTotal { get; set; }
    public int? CurrentGuestCount { get; set; }

    /// <summary>The next confirmed reservation that has not ended yet.</summary>
    public UpcomingReservationResponse? UpcomingReservation { get; set; }

    /// <summary>Tables with orders or reservations can only be deactivated, not deleted.</summary>
    public bool HasHistory { get; set; }
}

public class UpcomingReservationResponse
{
    public int Id { get; set; }
    public string GuestName { get; set; } = string.Empty;
    public int PartySize { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
}
