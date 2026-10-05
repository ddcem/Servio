using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class Refund : IEntity
{
    public int Id { get; set; }
    public int PaymentId { get; set; }
    public decimal Amount { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string? PayPalRefundId { get; set; }
    public RefundStatus Status { get; set; }
    public int RefundedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }

    public Payment Payment { get; set; } = null!;
    public User RefundedByUser { get; set; } = null!;
}
