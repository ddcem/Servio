namespace Servio.Services.Notifications;

/// <summary>
/// Names of the SignalR events the clients listen to.
/// </summary>
public static class RealtimeEvents
{
    /// <summary>Sent only to the recipient; carries a NotificationResponse.</summary>
    public const string NotificationReceived = "NotificationReceived";

    /// <summary>Kitchen/bar tickets changed: station displays reload.</summary>
    public const string TicketsChanged = "TicketsChanged";

    /// <summary>Orders or table occupancy changed: table grid and active orders reload.</summary>
    public const string OrdersChanged = "OrdersChanged";

    public const string ReservationsChanged = "ReservationsChanged";

    /// <summary>Menu items or their availability changed: waiters reload the menu.</summary>
    public const string MenuChanged = "MenuChanged";
}
