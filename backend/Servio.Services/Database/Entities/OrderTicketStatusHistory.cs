using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class OrderTicketStatusHistory : IEntity
{
    public int Id { get; set; }
    public int OrderTicketId { get; set; }
    public TicketStatus? FromStatus { get; set; }
    public TicketStatus ToStatus { get; set; }
    public int ChangedByUserId { get; set; }
    public string? Reason { get; set; }
    public DateTime ChangedAt { get; set; }

    public OrderTicket OrderTicket { get; set; } = null!;
    public User ChangedByUser { get; set; } = null!;
}
