using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class Order : IEntity
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public int TableId { get; set; }
    public int GuestCount { get; set; }
    public int WaiterId { get; set; }
    public OrderStatus Status { get; set; }
    /// <summary>Sum of the items at menu prices, which include VAT.</summary>
    public decimal Subtotal { get; set; }
    /// <summary>VAT rate in percent, copied from the settings when the order was opened.</summary>
    public decimal TaxRate { get; set; }
    /// <summary>The VAT contained in <see cref="Total"/> (shown on the receipt; not added on top).</summary>
    public decimal TaxAmount { get; set; }
    /// <summary>Amount due before the tip; equal to <see cref="Subtotal"/> because prices include VAT.</summary>
    public decimal Total { get; set; }
    public int CurrencyId { get; set; }
    public DateTime OpenedAt { get; set; }
    public DateTime? ClosedAt { get; set; }
    public int? CancelledByUserId { get; set; }
    public string? CancellationReason { get; set; }

    public RestaurantTable Table { get; set; } = null!;
    public User Waiter { get; set; } = null!;
    public Currency Currency { get; set; } = null!;
    public User? CancelledByUser { get; set; }
    public ICollection<OrderTicket> Tickets { get; set; } = [];
    public ICollection<OrderItem> Items { get; set; } = [];
    public ICollection<Payment> Payments { get; set; } = [];
}
