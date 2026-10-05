using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class ReservationStatusHistory
{
    public int Id { get; set; }
    public int ReservationId { get; set; }
    public ReservationStatus? FromStatus { get; set; }
    public ReservationStatus ToStatus { get; set; }
    public int ChangedByUserId { get; set; }
    public string? Reason { get; set; }
    public DateTime ChangedAt { get; set; }

    public Reservation Reservation { get; set; } = null!;
    public User ChangedByUser { get; set; } = null!;
}
