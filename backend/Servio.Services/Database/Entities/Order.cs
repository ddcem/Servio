using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class Order
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public int TableId { get; set; }
    public int WaiterId { get; set; }
    public OrderStatus Status { get; set; }
    public decimal Subtotal { get; set; }
    public decimal TaxRate { get; set; }
    public decimal TaxAmount { get; set; }
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
