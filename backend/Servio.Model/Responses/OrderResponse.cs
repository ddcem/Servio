using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class OrderResponse
{
    public int Id { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public int TableId { get; set; }
    public int TableNumber { get; set; }
    public int GuestCount { get; set; }
    public int WaiterId { get; set; }
    public string WaiterName { get; set; } = string.Empty;
    public OrderStatus Status { get; set; }
    /// <summary>Sum of the items at menu prices, which include VAT.</summary>
    public decimal Subtotal { get; set; }
    /// <summary>VAT rate in percent, copied from the settings when the order was opened.</summary>
    public decimal TaxRate { get; set; }
    /// <summary>The VAT contained in <see cref="Total"/> (shown on the receipt; not added on top).</summary>
    public decimal TaxAmount { get; set; }
    /// <summary>Amount due before the tip; equal to <see cref="Subtotal"/> because prices include VAT.</summary>
    public decimal Total { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencySymbol { get; set; } = string.Empty;
    public DateTime OpenedAt { get; set; }
    public DateTime? ClosedAt { get; set; }
    public string? CancellationReason { get; set; }
    public bool IsPaid { get; set; }
    /// <summary>False when PayPal does not accept the order's currency (e.g. BAM).</summary>
    public bool PayPalAvailable { get; set; }
    public List<OrderItemResponse> Items { get; set; } = [];
    public List<OrderTicketSummaryResponse> Tickets { get; set; } = [];
}

public class OrderItemResponse
{
    public int Id { get; set; }
    public int MenuItemId { get; set; }
    public string MenuItemName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineTotal { get; set; }
    public string? Note { get; set; }
    public int OrderTicketId { get; set; }
    public TicketStatus TicketStatus { get; set; }
}

public class OrderTicketSummaryResponse
{
    public int Id { get; set; }
    public string TicketNumber { get; set; } = string.Empty;
    public string StationName { get; set; } = string.Empty;
    public TicketStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
