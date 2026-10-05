using Servio.Model.Enums;

namespace Servio.Services.StateMachines;

/// <summary>
/// The single definition of every status workflow in the system.
/// </summary>
public static class StatusWorkflows
{
    public static readonly StateMachine<ReservationStatus> Reservation = new("Reservation",
        new Dictionary<ReservationStatus, ReservationStatus[]>
        {
            [ReservationStatus.Pending] = [ReservationStatus.Confirmed, ReservationStatus.Cancelled],
            [ReservationStatus.Confirmed] = [ReservationStatus.Completed, ReservationStatus.NoShow, ReservationStatus.Cancelled]
        });

    public static readonly StateMachine<TicketStatus> Ticket = new("Ticket",
        new Dictionary<TicketStatus, TicketStatus[]>
        {
            [TicketStatus.New] = [TicketStatus.Preparing, TicketStatus.Cancelled],
            [TicketStatus.Preparing] = [TicketStatus.Ready],
            [TicketStatus.Ready] = [TicketStatus.Served]
        });

    public static readonly StateMachine<OrderStatus> Order = new("Order",
        new Dictionary<OrderStatus, OrderStatus[]>
        {
            [OrderStatus.Open] = [OrderStatus.Completed, OrderStatus.Cancelled]
        });

    public static readonly StateMachine<PaymentStatus> Payment = new("Payment",
        new Dictionary<PaymentStatus, PaymentStatus[]>
        {
            [PaymentStatus.Pending] = [PaymentStatus.Completed, PaymentStatus.Failed, PaymentStatus.Cancelled],
            [PaymentStatus.Completed] = [PaymentStatus.PartiallyRefunded, PaymentStatus.Refunded],
            [PaymentStatus.PartiallyRefunded] = [PaymentStatus.PartiallyRefunded, PaymentStatus.Refunded]
        });
}
