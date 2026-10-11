using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Localization;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Common;
using Servio.Services.Database.Entities;
using Servio.Services.Database;
using Servio.Services.Localization;
using Servio.Services.Notifications;
using Servio.Services.Payments.PayPal;
using Servio.Services.StateMachines;
using Servio.Services.Tables;

namespace Servio.Services.Payments;

/// <summary>
/// Payments are always finalised on the server: cash is recorded by the waiter, PayPal is
/// captured through the PayPal API. Amounts come from the order, never from the client.
/// </summary>
public class PaymentService(
    ServioDbContext context,
    ICurrentUserService currentUser,
    IPayPalClient payPalClient,
    INotificationDispatcher dispatcher,
    ILogger<PaymentService> logger)
    : BaseReadService<Payment, PaymentResponse, PaymentSearchObject>(context), IPaymentService
{
    private static readonly RefundStatus[] CountedRefundStatuses = [RefundStatus.Pending, RefundStatus.Completed];
    private static readonly PaymentStatus[] RefundablePaymentStatuses = [PaymentStatus.Completed, PaymentStatus.PartiallyRefunded];

    protected override string EntityName => "Payment";

    protected override Expression<Func<Payment, PaymentResponse>> Projection => x => new PaymentResponse
    {
        Id = x.Id,
        OrderId = x.OrderId,
        OrderNumber = x.Order.OrderNumber,
        TableNumber = x.Order.Table.Number,
        PaymentMethod = x.PaymentMethod.Name,
        Status = x.Status,
        OrderTotal = x.Order.Total,
        TipPercent = x.TipPercent,
        TipAmount = x.TipAmount,
        Amount = x.Amount,
        CashReceived = x.CashReceived,
        ChangeGiven = x.ChangeGiven,
        CapturedAmount = x.CapturedAmount,
        RefundedAmount = x.Refunds.Where(r => CountedRefundStatuses.Contains(r.Status)).Sum(r => r.Amount),
        RefundableAmount = RefundablePaymentStatuses.Contains(x.Status)
            ? (x.CapturedAmount ?? 0) - x.Refunds.Where(r => CountedRefundStatuses.Contains(r.Status)).Sum(r => r.Amount)
            : 0,
        CurrencyCode = x.Order.Currency.Code,
        CurrencySymbol = x.Order.Currency.Symbol,
        ProcessedByName = x.ProcessedByUser.FirstName + " " + x.ProcessedByUser.LastName,
        CreatedAt = x.CreatedAt,
        CompletedAt = x.CompletedAt
    };

    protected override Expression<Func<Payment, PaymentResponse>> DetailsProjection => x => new PaymentResponse
    {
        Id = x.Id,
        OrderId = x.OrderId,
        OrderNumber = x.Order.OrderNumber,
        TableNumber = x.Order.Table.Number,
        PaymentMethod = x.PaymentMethod.Name,
        Status = x.Status,
        OrderTotal = x.Order.Total,
        TipPercent = x.TipPercent,
        TipAmount = x.TipAmount,
        Amount = x.Amount,
        CashReceived = x.CashReceived,
        ChangeGiven = x.ChangeGiven,
        CapturedAmount = x.CapturedAmount,
        RefundedAmount = x.Refunds.Where(r => CountedRefundStatuses.Contains(r.Status)).Sum(r => r.Amount),
        RefundableAmount = RefundablePaymentStatuses.Contains(x.Status)
            ? (x.CapturedAmount ?? 0) - x.Refunds.Where(r => CountedRefundStatuses.Contains(r.Status)).Sum(r => r.Amount)
            : 0,
        CurrencyCode = x.Order.Currency.Code,
        CurrencySymbol = x.Order.Currency.Symbol,
        ProcessedByName = x.ProcessedByUser.FirstName + " " + x.ProcessedByUser.LastName,
        CreatedAt = x.CreatedAt,
        CompletedAt = x.CompletedAt,
        Refunds = x.Refunds
            .OrderByDescending(r => r.CreatedAt)
            .Select(r => new RefundResponse
            {
                Id = r.Id,
                Amount = r.Amount,
                Reason = r.Reason,
                Status = r.Status,
                RefundedByName = r.RefundedByUser.FirstName + " " + r.RefundedByUser.LastName,
                CreatedAt = r.CreatedAt
            })
            .ToList()
    };

    protected override IQueryable<Payment> ApplyFilter(IQueryable<Payment> query, PaymentSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            query = int.TryParse(fts, out var tableNumber)
                ? query.Where(x => x.Order.Table.Number == tableNumber || EF.Functions.ILike(x.Order.OrderNumber, ContainsPattern(fts)))
                : query.Where(x => EF.Functions.ILike(x.Order.OrderNumber, ContainsPattern(fts)));
        }

        if (search.OrderId is { } orderId)
        {
            query = query.Where(x => x.OrderId == orderId);
        }

        if (search.PaymentMethodId is { } methodId)
        {
            query = query.Where(x => x.PaymentMethodId == methodId);
        }

        if (search.Status is { } status)
        {
            query = query.Where(x => x.Status == status);
        }

        if (search.From.AsUtc() is { } from)
        {
            query = query.Where(x => x.CreatedAt >= from);
        }

        if (search.To.AsUtc() is { } to)
        {
            query = query.Where(x => x.CreatedAt <= to);
        }

        return query;
    }

    protected override IQueryable<Payment> ApplyOrdering(IQueryable<Payment> query, PaymentSearchObject search) =>
        query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id);

    public async Task<PaymentResponse> PayCashAsync(CashPaymentRequest request, CancellationToken cancellationToken = default)
    {
        var order = await LoadPayableOrderAsync(request.OrderId!.Value, cancellationToken);
        await TableAccess.EnsureCanServeAsync(Context, currentUser, order.Table, cancellationToken);
        var (tipAmount, amount) = CalculateAmount(order, request.TipPercent!.Value);
        var cashReceived = request.CashReceived!.Value;

        if (cashReceived < amount)
        {
            throw new BusinessException(
                "Cash received ({0}) is less than the amount due ({1}).", new LocalizedMoney(cashReceived, order.Currency.Symbol), new LocalizedMoney(amount, order.Currency.Symbol));
        }

        CancelAbandonedCheckouts(order);

        var now = DateTime.UtcNow;
        var payment = new Payment
        {
            Order = order,
            PaymentMethodId = await GetPaymentMethodIdAsync(PaymentMethods.Cash, cancellationToken),
            Status = PaymentStatus.Completed,
            TipPercent = request.TipPercent!.Value,
            TipAmount = tipAmount,
            Amount = amount,
            CashReceived = cashReceived,
            ChangeGiven = cashReceived - amount,
            CapturedAmount = amount,
            ProcessedByUserId = currentUser.UserId,
            CreatedAt = now,
            CompletedAt = now
        };
        Context.Payments.Add(payment);

        await CompleteOrderAsync(order, payment, PaymentMethods.Cash, cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(payment.Id, cancellationToken);
    }

    public async Task<PayPalCheckoutResponse> StartPayPalAsync(PayPalPaymentRequest request, CancellationToken cancellationToken = default)
    {
        var order = await LoadPayableOrderAsync(request.OrderId!.Value, cancellationToken);
        await TableAccess.EnsureCanServeAsync(Context, currentUser, order.Table, cancellationToken);
        if (!PayPalCurrencies.Supported.Contains(order.Currency.Code))
        {
            throw new BusinessException("PayPal does not accept payments in {0}. Please take the payment in cash.", order.Currency.Code);
        }

        var (tipAmount, amount) = CalculateAmount(order, request.TipPercent!.Value);

        CancelAbandonedCheckouts(order);

        var checkout = await payPalClient.CreateOrderAsync(
            referenceId: order.OrderNumber,
            description: $"Table {order.Table.Number}, order {order.OrderNumber}",
            amount: amount,
            currencyCode: order.Currency.Code,
            cancellationToken);

        var payment = new Payment
        {
            Order = order,
            PaymentMethodId = await GetPaymentMethodIdAsync(PaymentMethods.PayPal, cancellationToken),
            Status = PaymentStatus.Pending,
            TipPercent = request.TipPercent!.Value,
            TipAmount = tipAmount,
            Amount = amount,
            PayPalOrderId = checkout.OrderId,
            ProcessedByUserId = currentUser.UserId,
            CreatedAt = DateTime.UtcNow
        };
        Context.Payments.Add(payment);

        await Context.SaveChangesAsync(cancellationToken);

        return new PayPalCheckoutResponse
        {
            PaymentId = payment.Id,
            PayPalOrderId = checkout.OrderId,
            ApprovalUrl = checkout.ApprovalUrl,
            Amount = amount,
            CurrencyCode = order.Currency.Code
        };
    }

    public async Task<PaymentResponse> CapturePayPalAsync(int id, CancellationToken cancellationToken = default)
    {
        var payment = await LoadPaymentAsync(id, cancellationToken);
        await TableAccess.EnsureCanServeAsync(Context, currentUser, payment.Order.Table, cancellationToken);

        // Idempotent: a repeated confirmation does not capture or close the order again.
        if (payment.Status != PaymentStatus.Pending)
        {
            if (payment.Status is PaymentStatus.Completed or PaymentStatus.PartiallyRefunded or PaymentStatus.Refunded)
            {
                return await GetByIdAsync(id, cancellationToken);
            }

            throw new BusinessException("This payment was {0}. Start a new payment.", payment.Status);
        }

        if (payment.PayPalOrderId is null)
        {
            throw new BusinessException("This is not a PayPal payment.");
        }

        EnsureOrderPayable(payment.Order);

        var capture = await payPalClient.CaptureOrderAsync(payment.PayPalOrderId, $"servio-capture-{payment.Id}", cancellationToken);
        if (!capture.IsCompleted)
        {
            logger.LogWarning("PayPal order {PayPalOrderId} for payment {PaymentId} returned {OrderStatus}/{CaptureStatus}",
                payment.PayPalOrderId, payment.Id, capture.OrderStatus, capture.CaptureStatus);

            if (capture.CaptureStatus is "DECLINED" or "FAILED")
            {
                StatusWorkflows.Payment.EnsureCanTransition(payment.Status, PaymentStatus.Failed);
                payment.Status = PaymentStatus.Failed;
                await Context.SaveChangesAsync(cancellationToken);
                throw new BusinessException("PayPal declined the payment. Ask the guest to try again or pay in cash.");
            }

            throw new BusinessException("PayPal has not completed the payment yet. Try confirming again in a moment.");
        }

        if (capture.Amount != payment.Amount)
        {
            logger.LogWarning("PayPal captured {Captured} for payment {PaymentId}, expected {Expected}",
                capture.Amount, payment.Id, payment.Amount);
        }

        StatusWorkflows.Payment.EnsureCanTransition(payment.Status, PaymentStatus.Completed);
        payment.Status = PaymentStatus.Completed;
        payment.PayPalCaptureId = capture.CaptureId;
        payment.CapturedAmount = capture.Amount;
        payment.CompletedAt = DateTime.UtcNow;

        await CompleteOrderAsync(payment.Order, payment, PaymentMethods.PayPal, cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<PaymentResponse> CancelAsync(int id, CancellationToken cancellationToken = default)
    {
        var payment = await LoadPaymentAsync(id, cancellationToken);
        await TableAccess.EnsureCanServeAsync(Context, currentUser, payment.Order.Table, cancellationToken);
        if (payment.Status == PaymentStatus.Cancelled)
        {
            return await GetByIdAsync(id, cancellationToken);
        }

        StatusWorkflows.Payment.EnsureCanTransition(payment.Status, PaymentStatus.Cancelled);
        payment.Status = PaymentStatus.Cancelled;

        await Context.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<PaymentResponse> RefundAsync(int id, RefundRequest request, CancellationToken cancellationToken = default)
    {
        var payment = await LoadPaymentAsync(id, cancellationToken);
        await Context.Entry(payment).Collection(x => x.Refunds).LoadAsync(cancellationToken);

        if (!RefundablePaymentStatuses.Contains(payment.Status) || payment.CapturedAmount is null)
        {
            throw new BusinessException("A {0} payment cannot be refunded.", payment.Status);
        }

        // Refunds are limited by what was actually charged, not by the order total.
        var alreadyRefunded = payment.Refunds.Where(x => CountedRefundStatuses.Contains(x.Status)).Sum(x => x.Amount);
        var refundable = payment.CapturedAmount.Value - alreadyRefunded;
        var amount = Money.Round(request.Amount!.Value);
        var symbol = payment.Order.Currency.Symbol;

        if (amount > refundable)
        {
            throw new BusinessException(
                "At most {0} can still be refunded (charged {1}, already refunded {2}).", new LocalizedMoney(refundable, symbol), new LocalizedMoney(payment.CapturedAmount.Value, symbol), new LocalizedMoney(alreadyRefunded, symbol));
        }

        var reason = request.Reason.Trim();
        var refund = new Refund
        {
            Payment = payment,
            Amount = amount,
            Reason = reason,
            RefundedByUserId = currentUser.UserId,
            CreatedAt = DateTime.UtcNow,
            Status = RefundStatus.Completed
        };

        if (payment.PaymentMethod.Name == PaymentMethods.PayPal)
        {
            var result = await payPalClient.RefundCaptureAsync(payment.PayPalCaptureId!, amount, payment.Order.Currency.Code,
                reason, Guid.NewGuid().ToString("N"), cancellationToken);

            refund.PayPalRefundId = result.RefundId;
            refund.Status = result.IsCompleted ? RefundStatus.Completed
                : result.IsFailed ? RefundStatus.Failed
                : RefundStatus.Pending;
        }

        payment.Refunds.Add(refund);

        if (refund.Status == RefundStatus.Failed)
        {
            await Context.SaveChangesAsync(cancellationToken);
            throw new BusinessException("PayPal could not complete the refund. No money was returned; try again later.");
        }

        var newStatus = alreadyRefunded + amount >= payment.CapturedAmount.Value
            ? PaymentStatus.Refunded
            : PaymentStatus.PartiallyRefunded;
        StatusWorkflows.Payment.EnsureCanTransition(payment.Status, newStatus);
        payment.Status = newStatus;

        await dispatcher.NotifyAsync(payment.ProcessedByUserId, NotificationType.RefundIssued,
            new LocalizedText("Refund issued – order {0}", payment.Order.OrderNumber),
            new LocalizedText("{0} returned to the guest ({1}). Reason: {2}",
                new LocalizedMoney(amount, symbol), new Localized(payment.PaymentMethod.Name), reason),
            cancellationToken: cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await dispatcher.FlushAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    private async Task<Order> LoadPayableOrderAsync(int orderId, CancellationToken cancellationToken)
    {
        var order = await Context.Orders
            .Include(x => x.Table)
            .Include(x => x.Currency)
            .Include(x => x.Tickets).ThenInclude(x => x.Station)
            .Include(x => x.Payments)
            .AsSplitQuery()
            .FirstOrDefaultAsync(x => x.Id == orderId, cancellationToken)
            ?? throw new NotFoundException("Order was not found.");

        EnsureOrderPayable(order);

        if (order.Payments.Any(x => x.Status == PaymentStatus.Completed))
        {
            throw new BusinessException("Order {0} is already paid.", order.OrderNumber);
        }

        return order;
    }

    private async Task<Payment> LoadPaymentAsync(int id, CancellationToken cancellationToken) =>
        await Context.Payments
            .Include(x => x.PaymentMethod)
            .Include(x => x.Order).ThenInclude(x => x.Table)
            .Include(x => x.Order).ThenInclude(x => x.Currency)
            .Include(x => x.Order).ThenInclude(x => x.Tickets).ThenInclude(x => x.Station)
            .AsSplitQuery()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken)
        ?? throw NotFound();

    /// <summary>The bill can be settled once nothing is waiting at the kitchen or bar.</summary>
    private static void EnsureOrderPayable(Order order)
    {
        if (order.Status != OrderStatus.Open)
        {
            throw new BusinessException("Order {0} is already {1}.", order.OrderNumber, order.Status);
        }

        var inProgress = order.Tickets.FirstOrDefault(x => x.Status is TicketStatus.New or TicketStatus.Preparing);
        if (inProgress is not null)
        {
            throw new BusinessException(
                "Ticket {0} ({1}) is still being prepared. The bill can be paid once everything is ready or served.", inProgress.TicketNumber, new Localized(inProgress.Station.Name.ToLower()));
        }

        if (order.Total <= 0)
        {
            throw new BusinessException("There is nothing to pay on this order. Cancel it instead.");
        }
    }

    /// <summary>
    /// A PayPal checkout the guest did not finish is replaced by the new payment attempt.
    /// It was never captured, so no money moved.
    /// </summary>
    private static void CancelAbandonedCheckouts(Order order)
    {
        foreach (var abandoned in order.Payments.Where(x => x.Status == PaymentStatus.Pending))
        {
            StatusWorkflows.Payment.EnsureCanTransition(abandoned.Status, PaymentStatus.Cancelled);
            abandoned.Status = PaymentStatus.Cancelled;
        }
    }

    /// <summary>The tip is a percentage of the subtotal (before tax), as shown on the checkout screen.</summary>
    private static (decimal TipAmount, decimal Amount) CalculateAmount(Order order, int tipPercent)
    {
        var tipAmount = Money.Percent(order.Subtotal, tipPercent);
        return (tipAmount, order.Total + tipAmount);
    }

    private async Task<int> GetPaymentMethodIdAsync(string name, CancellationToken cancellationToken) =>
        await Context.PaymentMethods.Where(x => x.Name == name).Select(x => x.Id).FirstAsync(cancellationToken);

    /// <summary>Closes the order: food and drinks still waiting at the pass are handed over now.</summary>
    private async Task CompleteOrderAsync(Order order, Payment payment, string methodName, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        foreach (var ticket in order.Tickets.Where(x => x.Status == TicketStatus.Ready))
        {
            StatusWorkflows.Ticket.EnsureCanTransition(ticket.Status, TicketStatus.Served);
            ticket.StatusHistory.Add(new OrderTicketStatusHistory
            {
                FromStatus = ticket.Status,
                ToStatus = TicketStatus.Served,
                ChangedByUserId = currentUser.UserId,
                Reason = Translator.T("Served when the bill was paid"),
                ChangedAt = now
            });
            ticket.Status = TicketStatus.Served;
            ticket.ServedAt = now;
        }

        StatusWorkflows.Order.EnsureCanTransition(order.Status, OrderStatus.Completed);
        order.Status = OrderStatus.Completed;
        order.ClosedAt = now;

        await dispatcher.NotifyRoleAsync(Roles.Admin, NotificationType.PaymentCompleted,
            new LocalizedText("Table {0} paid", order.Table.Number),
            payment.TipAmount > 0
                ? new LocalizedText("Order {0}: {1} by {2}, including a {3} tip.", order.OrderNumber,
                    new LocalizedMoney(payment.Amount, order.Currency.Symbol), new Localized(methodName),
                    new LocalizedMoney(payment.TipAmount, order.Currency.Symbol))
                : new LocalizedText("Order {0}: {1} by {2}.", order.OrderNumber,
                    new LocalizedMoney(payment.Amount, order.Currency.Symbol), new Localized(methodName)),
            cancellationToken: cancellationToken);
    }

    private Task PublishChangesAsync(CancellationToken cancellationToken)
    {
        dispatcher.Broadcast(RealtimeEvents.OrdersChanged);
        dispatcher.Broadcast(RealtimeEvents.TicketsChanged);
        return dispatcher.FlushAsync(cancellationToken);
    }
}
