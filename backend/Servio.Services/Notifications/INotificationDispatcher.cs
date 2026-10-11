using Servio.Model.Enums;
using Servio.Model.Localization;
using Servio.Services.Database.Entities;

namespace Servio.Services.Notifications;

/// <summary>
/// Collects notifications during a business operation. They are added to the shared DbContext
/// (saved by the caller together with the operation) and pushed live by <see cref="FlushAsync"/>
/// once the caller has saved.
/// </summary>
public interface INotificationDispatcher
{
    /// <summary>Notifies one user; the texts are written in that user's language.</summary>
    Task NotifyAsync(int userId, NotificationType type, LocalizedText title, LocalizedText body,
        OrderTicket? ticket = null, Reservation? reservation = null, CancellationToken cancellationToken = default);

    /// <summary>Notifies every active user of a role, each in their own language.</summary>
    Task NotifyRoleAsync(string role, NotificationType type, LocalizedText title, LocalizedText body,
        OrderTicket? ticket = null, Reservation? reservation = null, CancellationToken cancellationToken = default);

    void Broadcast(string eventName);

    Task FlushAsync(CancellationToken cancellationToken = default);
}
