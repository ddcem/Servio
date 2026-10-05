using System.Globalization;
using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Servio.Model.Exceptions;
using Servio.Services.Configuration;

namespace Servio.Services.Payments.PayPal;

/// <summary>
/// Typed HttpClient (created by IHttpClientFactory). The OAuth token is cached until shortly before it expires.
/// </summary>
public class PayPalClient(
    HttpClient httpClient,
    IOptions<PayPalOptions> options,
    IMemoryCache cache,
    ILogger<PayPalClient> logger) : IPayPalClient
{
    private const string TokenCacheKey = "paypal-access-token";
    private const string UnavailableMessage = "PayPal could not process the request right now. Please try again in a moment.";

    private readonly PayPalOptions _options = options.Value;

    public async Task<PayPalCheckout> CreateOrderAsync(string referenceId, string description, decimal amount,
        string currencyCode, CancellationToken cancellationToken = default)
    {
        var body = new
        {
            intent = "CAPTURE",
            purchase_units = new[]
            {
                new
                {
                    reference_id = referenceId,
                    description,
                    amount = new { currency_code = currencyCode, value = FormatAmount(amount) }
                }
            },
            payment_source = new
            {
                paypal = new
                {
                    experience_context = new
                    {
                        return_url = _options.ReturnUrl,
                        cancel_url = _options.CancelUrl,
                        user_action = "PAY_NOW",
                        shipping_preference = "NO_SHIPPING"
                    }
                }
            }
        };

        using var response = await SendAsync(HttpMethod.Post, "v2/checkout/orders", body, Guid.NewGuid().ToString("N"), cancellationToken);
        var order = await ReadAsync<PayPalOrderDto>(response, "create order", cancellationToken);

        var approvalUrl = order.Links?.FirstOrDefault(x => x.Rel is "payer-action" or "approve")?.Href
                          ?? throw ProviderError("create order", "no approval link in the response");

        return new PayPalCheckout(order.Id, approvalUrl);
    }

    public async Task<PayPalCapture> CaptureOrderAsync(string orderId, string requestId, CancellationToken cancellationToken = default)
    {
        using var response = await SendAsync(HttpMethod.Post, $"v2/checkout/orders/{orderId}/capture", new { }, requestId, cancellationToken);

        if (response.StatusCode == HttpStatusCode.UnprocessableEntity)
        {
            var error = await response.Content.ReadFromJsonAsync<PayPalErrorDto>(cancellationToken);
            var issue = error?.Details?.FirstOrDefault()?.Issue;

            switch (issue)
            {
                case "ORDER_ALREADY_CAPTURED":
                    return await GetCaptureAsync(orderId, cancellationToken);
                case "ORDER_NOT_APPROVED" or "PAYER_ACTION_REQUIRED":
                    throw new BusinessException("The guest has not approved the payment in PayPal yet.");
                case "INSTRUMENT_DECLINED" or "PAYER_CANNOT_PAY":
                    throw new BusinessException("PayPal declined the payment method. Ask the guest to choose another one or pay in cash.");
                default:
                    logger.LogWarning("PayPal capture of order {OrderId} rejected: {Issue} (debug id {DebugId})",
                        orderId, issue, error?.DebugId);
                    throw new PaymentProviderException(UnavailableMessage);
            }
        }

        return ToCapture(await ReadAsync<PayPalOrderDto>(response, "capture order", cancellationToken));
    }

    public async Task<PayPalRefund> RefundCaptureAsync(string captureId, decimal amount, string currencyCode, string note,
        string requestId, CancellationToken cancellationToken = default)
    {
        var body = new
        {
            amount = new { currency_code = currencyCode, value = FormatAmount(amount) },
            note_to_payer = note.Length > 255 ? note[..255] : note
        };

        using var response = await SendAsync(HttpMethod.Post, $"v2/payments/captures/{captureId}/refund", body, requestId, cancellationToken);
        var refund = await ReadAsync<PayPalRefundDto>(response, "refund capture", cancellationToken);
        return new PayPalRefund(refund.Id, refund.Status);
    }

    private async Task<PayPalCapture> GetCaptureAsync(string orderId, CancellationToken cancellationToken)
    {
        using var response = await SendAsync(HttpMethod.Get, $"v2/checkout/orders/{orderId}", null, null, cancellationToken);
        return ToCapture(await ReadAsync<PayPalOrderDto>(response, "get order", cancellationToken));
    }

    private static PayPalCapture ToCapture(PayPalOrderDto order)
    {
        var capture = order.PurchaseUnits?.FirstOrDefault()?.Payments?.Captures?.FirstOrDefault();
        return new PayPalCapture(
            order.Status,
            capture?.Id,
            capture?.Status,
            capture is null ? null : decimal.Parse(capture.Amount.Value, CultureInfo.InvariantCulture));
    }

    private async Task<HttpResponseMessage> SendAsync(HttpMethod method, string path, object? body, string? requestId,
        CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(method, path);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", await GetAccessTokenAsync(cancellationToken));

        if (requestId is not null)
        {
            // PayPal applies the same request id only once, so retries cannot charge or refund twice.
            request.Headers.Add("PayPal-Request-Id", requestId);
        }

        if (body is not null)
        {
            request.Content = JsonContent.Create(body);
        }

        try
        {
            return await httpClient.SendAsync(request, cancellationToken);
        }
        catch (HttpRequestException ex)
        {
            logger.LogError(ex, "PayPal request {Method} {Path} failed", method, path);
            throw new PaymentProviderException(UnavailableMessage);
        }
    }

    private async Task<string> GetAccessTokenAsync(CancellationToken cancellationToken)
    {
        if (cache.TryGetValue(TokenCacheKey, out string? token) && token is not null)
        {
            return token;
        }

        using var request = new HttpRequestMessage(HttpMethod.Post, "v1/oauth2/token")
        {
            Content = new FormUrlEncodedContent([new KeyValuePair<string, string>("grant_type", "client_credentials")])
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Basic",
            Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_options.ClientId}:{_options.ClientSecret}")));

        HttpResponseMessage response;
        try
        {
            response = await httpClient.SendAsync(request, cancellationToken);
        }
        catch (HttpRequestException ex)
        {
            logger.LogError(ex, "PayPal authentication request failed");
            throw new PaymentProviderException(UnavailableMessage);
        }

        using (response)
        {
            var result = await ReadAsync<PayPalTokenResponse>(response, "authenticate", cancellationToken);
            cache.Set(TokenCacheKey, result.AccessToken, TimeSpan.FromSeconds(Math.Max(60, result.ExpiresIn - 300)));
            return result.AccessToken;
        }
    }

    private async Task<T> ReadAsync<T>(HttpResponseMessage response, string operation, CancellationToken cancellationToken)
    {
        if (!response.IsSuccessStatusCode)
        {
            var content = await response.Content.ReadAsStringAsync(cancellationToken);
            throw ProviderError(operation, $"HTTP {(int)response.StatusCode}: {content}");
        }

        return await response.Content.ReadFromJsonAsync<T>(cancellationToken)
               ?? throw ProviderError(operation, "empty response");
    }

    private PaymentProviderException ProviderError(string operation, string details)
    {
        logger.LogError("PayPal {Operation} failed: {Details}", operation, details);
        return new PaymentProviderException(UnavailableMessage);
    }

    private static string FormatAmount(decimal amount) => amount.ToString("0.00", CultureInfo.InvariantCulture);
}
