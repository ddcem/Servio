using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class OrderTicket : IEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int StationId { get; set; }
    public string TicketNumber { get; set; } = string.Empty;
    public TicketStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? ReadyAt { get; set; }
    public DateTime? ServedAt { get; set; }
    public int? StartedByUserId { get; set; }
    public int? ReadyByUserId { get; set; }

    public Order Order { get; set; } = null!;
    public PreparationStation Station { get; set; } = null!;
    public User? StartedByUser { get; set; }
    public User? ReadyByUser { get; set; }
    public ICollection<OrderItem> Items { get; set; } = [];
    public ICollection<OrderTicketStatusHistory> StatusHistory { get; set; } = [];
}
