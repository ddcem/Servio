using Servio.Model.Enums;

namespace Servio.Model.Responses;

/// <summary>
/// A ticket as shown on the kitchen or bar display.
/// </summary>
public class OrderTicketResponse
{
    public int Id { get; set; }
    public string TicketNumber { get; set; } = string.Empty;
    public int OrderId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public int TableNumber { get; set; }
    public string WaiterName { get; set; } = string.Empty;
    public int StationId { get; set; }
    public string StationName { get; set; } = string.Empty;
    public TicketStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? ReadyAt { get; set; }
    public DateTime? ServedAt { get; set; }
    public List<OrderTicketItemResponse> Items { get; set; } = [];
}

public class OrderTicketItemResponse
{
    public string MenuItemName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public string? Note { get; set; }
}
