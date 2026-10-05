using Servio.Model.Enums;
using Servio.Services.Database.Entities;

namespace Servio.Services.Notifications;

/// <summary>
/// Collects notifications during a business operation. They are added to the shared DbContext
/// (saved by the caller together with the operation) and pushed live by <see cref="FlushAsync"/>
/// once the caller has saved.
/// </summary>
public interface INotificationDispatcher
{
    void Notify(int userId, NotificationType type, string title, string body,
        OrderTicket? ticket = null, Reservation? reservation = null);

    Task NotifyRoleAsync(string role, NotificationType type, string title, string body,
        OrderTicket? ticket = null, Reservation? reservation = null, CancellationToken cancellationToken = default);

    void Broadcast(string eventName);

    Task FlushAsync(CancellationToken cancellationToken = default);
}
