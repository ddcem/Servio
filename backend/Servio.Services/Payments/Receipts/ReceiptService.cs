using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Services.Common;
using Servio.Services.Database;
using Servio.Services.Settings;

namespace Servio.Services.Payments.Receipts;

public class ReceiptService(ServioDbContext context, ISettingsService settingsService, IRestaurantClock clock) : IReceiptService
{
    private static readonly PaymentStatus[] PaidStatuses = [PaymentStatus.Completed, PaymentStatus.PartiallyRefunded, PaymentStatus.Refunded];

    public async Task<byte[]> GetPdfAsync(int paymentId, CancellationToken cancellationToken = default)
    {
        var payment = await context.Payments
            .AsNoTracking()
            .Where(x => x.Id == paymentId)
            .Select(x => new
            {
                x.Status,
                x.Order.OrderNumber,
                TableNumber = x.Order.Table.Number,
                WaiterName = x.Order.Waiter.FirstName + " " + x.Order.Waiter.LastName,
                PaidAt = x.CompletedAt ?? x.CreatedAt,
                PaymentMethod = x.PaymentMethod.Name,
                CurrencySymbol = x.Order.Currency.Symbol,
                Lines = x.Order.Items
                    .Where(i => i.OrderTicket.Status != TicketStatus.Cancelled)
                    .OrderBy(i => i.Id)
                    .Select(i => new { i.MenuItem.Name, i.Quantity, i.UnitPrice })
                    .ToList(),
                x.Order.Total,
                x.Order.TaxRate,
                x.Order.TaxAmount,
                x.TipPercent,
                x.TipAmount,
                AmountPaid = x.CapturedAmount ?? x.Amount,
                x.CashReceived,
                x.ChangeGiven,
                Refunds = x.Refunds
                    .Where(r => r.Status == RefundStatus.Completed)
                    .OrderBy(r => r.CreatedAt)
                    .Select(r => new { r.CreatedAt, r.Amount, r.Reason })
                    .ToList()
            })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new NotFoundException("Payment was not found.");

        if (!PaidStatuses.Contains(payment.Status))
        {
            throw new BusinessException("A receipt is available once the payment is completed.");
        }

        var settings = await settingsService.GetAsync(cancellationToken);

        // The same item can appear in several rounds; the guest sees it once with the total quantity.
        var lines = payment.Lines
            .GroupBy(x => new { x.Name, x.UnitPrice })
            .Select(g => new ReceiptLine(g.Key.Name, g.Sum(x => x.Quantity), g.Key.UnitPrice, Money.Round(g.Key.UnitPrice * g.Sum(x => x.Quantity))))
            .ToList();

        var data = new ReceiptData(
            settings.RestaurantName,
            payment.OrderNumber,
            payment.TableNumber,
            payment.WaiterName,
            clock.FormatLocal(payment.PaidAt),
            payment.PaymentMethod,
            payment.CurrencySymbol,
            lines,
            payment.Total,
            payment.TaxRate,
            payment.TaxAmount,
            payment.TipPercent,
            payment.TipAmount,
            payment.AmountPaid,
            payment.CashReceived,
            payment.ChangeGiven,
            payment.Refunds.Select(r => new ReceiptRefund(clock.FormatLocal(r.CreatedAt), r.Amount, r.Reason)).ToList());

        return new ReceiptDocument(data).GeneratePdf();
    }
}
