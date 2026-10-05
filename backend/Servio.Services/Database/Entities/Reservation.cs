using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class Reservation : IEntity
{
    public int Id { get; set; }
    public int TableId { get; set; }
    public string GuestName { get; set; } = string.Empty;
    public string GuestPhone { get; set; } = string.Empty;
    public string? GuestEmail { get; set; }
    public int PartySize { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public ReservationStatus Status { get; set; }
    public string? Note { get; set; }
    public int CreatedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }

    public RestaurantTable Table { get; set; } = null!;
    public User CreatedByUser { get; set; } = null!;
    public ICollection<ReservationStatusHistory> StatusHistory { get; set; } = [];
}
