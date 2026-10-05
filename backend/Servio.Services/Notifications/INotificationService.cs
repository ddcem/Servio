using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Notifications;

/// <summary>
/// The current user's notifications. Users can only read and mark their own.
/// </summary>
public interface INotificationService : IReadService<NotificationResponse, NotificationSearchObject>
{
    Task<UnreadCountResponse> GetUnreadCountAsync(CancellationToken cancellationToken = default);
    Task<NotificationResponse> MarkAsReadAsync(int id, CancellationToken cancellationToken = default);
    Task MarkAllAsReadAsync(CancellationToken cancellationToken = default);
}
