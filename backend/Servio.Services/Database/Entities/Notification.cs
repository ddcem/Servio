using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class Notification
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public NotificationType Type { get; set; }
    public int? OrderTicketId { get; set; }
    public int? ReservationId { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }

    public User User { get; set; } = null!;
    public OrderTicket? OrderTicket { get; set; }
    public Reservation? Reservation { get; set; }
}
