using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Servio.Model.Enums;
using Servio.Model.Localization;
using Servio.Services.Database.Entities;
using Servio.Services.Database;
using Servio.Services.Localization;
using Servio.Services.Mapping;

namespace Servio.Services.Notifications;

public class NotificationDispatcher(
    ServioDbContext context,
    IRealtimeNotifier notifier,
    ILogger<NotificationDispatcher> logger) : INotificationDispatcher
{
    private const int TitleMaxLength = 100;
    private const int BodyMaxLength = 500;

    private readonly List<Notification> _pending = [];
    private readonly HashSet<string> _broadcasts = [];

    public async Task NotifyAsync(int userId, NotificationType type, LocalizedText title, LocalizedText body,
        OrderTicket? ticket = null, Reservation? reservation = null, CancellationToken cancellationToken = default)
    {
        var language = await context.Users
            .Where(x => x.Id == userId)
            .Select(x => x.PreferredLanguage)
            .FirstOrDefaultAsync(cancellationToken);
        Add(userId, language ?? Languages.English, type, title, body, ticket, reservation);
    }

    public async Task NotifyRoleAsync(string role, NotificationType type, LocalizedText title, LocalizedText body,
        OrderTicket? ticket = null, Reservation? reservation = null, CancellationToken cancellationToken = default)
    {
        var users = await context.Users
            .Where(x => x.IsActive && x.Role.Name == role)
            .Select(x => new { x.Id, x.PreferredLanguage })
            .ToListAsync(cancellationToken);

        foreach (var user in users)
        {
            Add(user.Id, user.PreferredLanguage, type, title, body, ticket, reservation);
        }
    }

    private void Add(int userId, string language, NotificationType type, LocalizedText title, LocalizedText body,
        OrderTicket? ticket, Reservation? reservation)
    {
        var notification = new Notification
        {
            UserId = userId,
            Type = type,
            Title = Truncate(Translator.Render(title, language), TitleMaxLength),
            Body = Truncate(Translator.Render(body, language), BodyMaxLength),
            OrderTicket = ticket,
            Reservation = reservation,
            CreatedAt = DateTime.UtcNow
        };

        context.Notifications.Add(notification);
        _pending.Add(notification);
    }

    public void Broadcast(string eventName) => _broadcasts.Add(eventName);

    public async Task FlushAsync(CancellationToken cancellationToken = default)
    {
        // The data is already committed at this point, so a failed push is logged
        // and the client picks the change up on its next reload.
        try
        {
            foreach (var notification in _pending)
            {
                await notifier.SendToUserAsync(notification.UserId, RealtimeEvents.NotificationReceived,
                    notification.ToResponse(), cancellationToken);
            }

            foreach (var eventName in _broadcasts)
            {
                await notifier.BroadcastAsync(eventName, cancellationToken);
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogWarning(ex, "Failed to push {Count} notifications and events {Events} to clients",
                _pending.Count, string.Join(", ", _broadcasts));
        }
        finally
        {
            _pending.Clear();
            _broadcasts.Clear();
        }
    }

    private static string Truncate(string value, int maxLength) =>
        value.Length <= maxLength ? value : value[..(maxLength - 1)] + "…";
}
