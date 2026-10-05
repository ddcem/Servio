using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Notifications;

namespace Servio.API.Controllers;

[Route("api/notifications")]
public class NotificationsController(INotificationService service)
    : BaseReadController<NotificationResponse, NotificationSearchObject>(service)
{
    [HttpGet("unread-count")]
    public async Task<ActionResult<UnreadCountResponse>> GetUnreadCount(CancellationToken cancellationToken) =>
        Ok(await service.GetUnreadCountAsync(cancellationToken));

    [HttpPut("{id:int}/read")]
    public async Task<ActionResult<NotificationResponse>> MarkAsRead(int id, CancellationToken cancellationToken) =>
        Ok(await service.MarkAsReadAsync(id, cancellationToken));

    [HttpPut("read-all")]
    public async Task<IActionResult> MarkAllAsRead(CancellationToken cancellationToken)
    {
        await service.MarkAllAsReadAsync(cancellationToken);
        return NoContent();
    }
}
