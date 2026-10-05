namespace Servio.Services.Database.Entities;

public class OrderItem
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int OrderTicketId { get; set; }
    public int MenuItemId { get; set; }
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public string? Note { get; set; }

    public Order Order { get; set; } = null!;
    public OrderTicket OrderTicket { get; set; } = null!;
    public MenuItem MenuItem { get; set; } = null!;
}
