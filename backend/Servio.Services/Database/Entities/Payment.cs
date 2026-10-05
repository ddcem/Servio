using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class Payment : IEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int PaymentMethodId { get; set; }
    public PaymentStatus Status { get; set; }
    public decimal TipPercent { get; set; }
    public decimal TipAmount { get; set; }
    public decimal Amount { get; set; }
    public decimal? CashReceived { get; set; }
    public decimal? ChangeGiven { get; set; }
    public string? PayPalOrderId { get; set; }
    public string? PayPalCaptureId { get; set; }
    public decimal? CapturedAmount { get; set; }
    public int ProcessedByUserId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    public Order Order { get; set; } = null!;
    public PaymentMethod PaymentMethod { get; set; } = null!;
    public User ProcessedByUser { get; set; } = null!;
    public ICollection<Refund> Refunds { get; set; } = [];
}
