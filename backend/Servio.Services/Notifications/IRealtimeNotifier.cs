namespace Servio.Services.Notifications;

/// <summary>
/// Pushes events to connected clients. Implemented with SignalR in the API project.
/// </summary>
public interface IRealtimeNotifier
{
    Task SendToUserAsync(int userId, string eventName, object payload, CancellationToken cancellationToken = default);

    /// <summary>Sends a payload-less "reload" signal to every connected staff member.</summary>
    Task BroadcastAsync(string eventName, CancellationToken cancellationToken = default);
}
