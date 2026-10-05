using Microsoft.AspNetCore.SignalR;
using Servio.API.Hubs;
using Servio.Services.Notifications;

namespace Servio.API.Realtime;

/// <summary>
/// SignalR identifies connections by the token's NameIdentifier claim (the user id).
/// </summary>
public class SignalRNotifier(IHubContext<NotificationHub> hubContext) : IRealtimeNotifier
{
    public Task SendToUserAsync(int userId, string eventName, object payload, CancellationToken cancellationToken = default) =>
        hubContext.Clients.User(userId.ToString()).SendAsync(eventName, payload, cancellationToken);

    public Task BroadcastAsync(string eventName, CancellationToken cancellationToken = default) =>
        hubContext.Clients.All.SendAsync(eventName, cancellationToken);
}
