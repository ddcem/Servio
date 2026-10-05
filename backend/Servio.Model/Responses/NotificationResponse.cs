using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class NotificationResponse
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Body { get; set; } = string.Empty;
    public NotificationType Type { get; set; }
    public bool IsRead { get; set; }
    public DateTime CreatedAt { get; set; }
    public int? OrderTicketId { get; set; }
    public int? ReservationId { get; set; }
}
