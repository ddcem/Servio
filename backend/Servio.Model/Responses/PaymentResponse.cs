using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class PaymentResponse
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public string OrderNumber { get; set; } = string.Empty;
    public int TableNumber { get; set; }
    public string PaymentMethod { get; set; } = string.Empty;
    public PaymentStatus Status { get; set; }
    public decimal OrderTotal { get; set; }
    public decimal TipPercent { get; set; }
    public decimal TipAmount { get; set; }
    public decimal Amount { get; set; }
    public decimal? CashReceived { get; set; }
    public decimal? ChangeGiven { get; set; }

    /// <summary>The amount actually charged; refunds are limited by it.</summary>
    public decimal? CapturedAmount { get; set; }
    public decimal RefundedAmount { get; set; }
    public decimal RefundableAmount { get; set; }

    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencySymbol { get; set; } = string.Empty;
    public string ProcessedByName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    /// <summary>Filled only on the details endpoint.</summary>
    public List<RefundResponse> Refunds { get; set; } = [];
}

public class RefundResponse
{
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public string Reason { get; set; } = string.Empty;
    public RefundStatus Status { get; set; }
    public string RefundedByName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
