using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Servio.API.Hubs;

/// <summary>
/// Live updates for the apps. Only authenticated staff can connect, and personal notifications are
/// addressed by the user id from the token, so a client can never subscribe to someone else's.
/// </summary>
[Authorize]
public class NotificationHub : Hub
{
    public const string Path = "/hubs/notifications";
}
