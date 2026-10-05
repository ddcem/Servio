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
    public decimal Subtotal { get; set; }
    public decimal TaxRate { get; set; }
    public decimal TaxAmount { get; set; }
    public decimal Total { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencySymbol { get; set; } = string.Empty;
    public DateTime OpenedAt { get; set; }
    public DateTime? ClosedAt { get; set; }
    public string? CancellationReason { get; set; }
    public bool IsPaid { get; set; }
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
