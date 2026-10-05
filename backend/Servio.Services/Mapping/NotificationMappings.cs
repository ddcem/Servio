using Servio.Model.Responses;
using Servio.Services.Database.Entities;

namespace Servio.Services.Mapping;

public static class NotificationMappings
{
    public static NotificationResponse ToResponse(this Notification notification) => new()
    {
        Id = notification.Id,
        Title = notification.Title,
        Body = notification.Body,
        Type = notification.Type,
        IsRead = notification.IsRead,
        CreatedAt = notification.CreatedAt,
        OrderTicketId = notification.OrderTicketId,
        ReservationId = notification.ReservationId
    };
}
