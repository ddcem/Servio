using Servio.Model.Enums;
using Servio.Services.Common;
using Servio.Services.Database.Entities;

namespace Servio.Services.Orders;

/// <summary>
/// Order totals are always computed on the server from the price snapshots on the order items.
/// Items on cancelled tickets are not charged.
/// </summary>
public static class OrderCalculator
{
    /// <summary>Expects <see cref="Order.Items"/> with their <see cref="OrderItem.OrderTicket"/> loaded.</summary>
    public static void Recalculate(Order order)
    {
        var subtotal = order.Items
            .Where(x => x.OrderTicket.Status != TicketStatus.Cancelled)
            .Sum(x => x.UnitPrice * x.Quantity);

        order.Subtotal = Money.Round(subtotal);
        order.TaxAmount = Money.Percent(order.Subtotal, order.TaxRate);
        order.Total = order.Subtotal + order.TaxAmount;
    }
}
