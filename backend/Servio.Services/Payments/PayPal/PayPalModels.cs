using System.Text.Json.Serialization;

namespace Servio.Services.Payments.PayPal;

public record PayPalCheckout(string OrderId, string ApprovalUrl);

/// <summary>Result of a capture: <see cref="IsCompleted"/> only when PayPal reports the money as captured.</summary>
public record PayPalCapture(string OrderStatus, string? CaptureId, string? CaptureStatus, decimal? Amount)
{
    public bool IsCompleted => OrderStatus == "COMPLETED" && CaptureStatus == "COMPLETED" && CaptureId is not null;
}

public record PayPalRefund(string RefundId, string Status)
{
    public bool IsCompleted => Status == "COMPLETED";
    public bool IsFailed => Status is "FAILED" or "CANCELLED";
}

internal record PayPalTokenResponse(
    [property: JsonPropertyName("access_token")] string AccessToken,
    [property: JsonPropertyName("expires_in")] int ExpiresIn);

internal record PayPalLink(string Href, string Rel);

internal record PayPalAmount(
    [property: JsonPropertyName("currency_code")] string CurrencyCode,
    string Value);

internal record PayPalCaptureDto(string Id, string Status, PayPalAmount Amount);

internal record PayPalPaymentsDto(List<PayPalCaptureDto>? Captures);

internal record PayPalPurchaseUnitDto(PayPalPaymentsDto? Payments);

internal record PayPalOrderDto(
    string Id,
    string Status,
    List<PayPalLink>? Links,
    [property: JsonPropertyName("purchase_units")] List<PayPalPurchaseUnitDto>? PurchaseUnits);

internal record PayPalRefundDto(string Id, string Status);

internal record PayPalErrorDetail(string? Issue, string? Description);

internal record PayPalErrorDto(
    string? Name,
    string? Message,
    [property: JsonPropertyName("debug_id")] string? DebugId,
    List<PayPalErrorDetail>? Details);
