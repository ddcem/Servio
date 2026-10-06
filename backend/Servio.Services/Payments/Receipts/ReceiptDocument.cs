using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Servio.Services.Common;

namespace Servio.Services.Payments.Receipts;

public record ReceiptLine(string Name, int Quantity, decimal UnitPrice, decimal Amount);

public record ReceiptRefund(string Date, decimal Amount, string Reason);

public record ReceiptData(
    string RestaurantName,
    string OrderNumber,
    int TableNumber,
    string WaiterName,
    string PaidAt,
    string PaymentMethod,
    string CurrencySymbol,
    IReadOnlyList<ReceiptLine> Lines,
    decimal Total,
    decimal TaxRate,
    decimal TaxAmount,
    decimal TipPercent,
    decimal TipAmount,
    decimal AmountPaid,
    decimal? CashReceived,
    decimal? ChangeGiven,
    IReadOnlyList<ReceiptRefund> Refunds);

/// <summary>
/// The guest's bill on an 80 mm receipt roll. Prices include VAT, so the VAT is shown as the part of
/// the total that is tax (base + VAT = total), not added on top.
/// </summary>
public class ReceiptDocument(ReceiptData data) : IDocument
{
    private const string Muted = "#6B7280";

    public void Compose(IDocumentContainer container)
    {
        string Amount(decimal value) => Money.Format(value, data.CurrencySymbol);

        container.Page(page =>
        {
            page.ContinuousSize(80, Unit.Millimetre);
            page.Margin(5, Unit.Millimetre);
            page.DefaultTextStyle(x => x.FontSize(8.5f).FontColor("#111827"));

            page.Content().Column(col =>
            {
                col.Spacing(2);
                col.Item().AlignCenter().Text(data.RestaurantName).FontSize(13).Bold();
                col.Item().AlignCenter().Text("RECEIPT").FontSize(9).LetterSpacing(0.2f).FontColor(Muted);
                Divider(col);

                Pair(col, "Order", data.OrderNumber);
                Pair(col, "Table", data.TableNumber.ToString());
                Pair(col, "Waiter", data.WaiterName);
                Pair(col, "Date", data.PaidAt);
                Divider(col);

                col.Item().Table(table =>
                {
                    table.ColumnsDefinition(columns =>
                    {
                        columns.RelativeColumn(3);
                        columns.RelativeColumn(1.6f);
                        columns.RelativeColumn(1.6f);
                    });
                    table.Header(header =>
                    {
                        header.Cell().Text("Item").SemiBold();
                        header.Cell().AlignRight().Text("Qty × price").SemiBold();
                        header.Cell().AlignRight().Text("Amount").SemiBold();
                    });
                    foreach (var line in data.Lines)
                    {
                        table.Cell().PaddingTop(2).Text(line.Name);
                        table.Cell().PaddingTop(2).AlignRight().Text($"{line.Quantity} × {line.UnitPrice:0.00}");
                        table.Cell().PaddingTop(2).AlignRight().Text(Amount(line.Amount));
                    }
                });
                Divider(col);

                col.Item().Row(row =>
                {
                    row.RelativeItem().Text("TOTAL").FontSize(12).Bold();
                    row.AutoItem().Text(Amount(data.Total)).FontSize(12).Bold();
                });
                col.Item().PaddingTop(4).Text($"VAT {data.TaxRate:0.##}% included in prices").FontSize(7.5f).FontColor(Muted);
                Pair(col, "Base (excl. VAT)", Amount(data.Total - data.TaxAmount));
                Pair(col, $"VAT {data.TaxRate:0.##}%", Amount(data.TaxAmount));
                Divider(col);

                if (data.TipAmount > 0)
                {
                    Pair(col, $"Tip ({data.TipPercent:0.##}%)", Amount(data.TipAmount));
                }
                col.Item().Row(row =>
                {
                    row.RelativeItem().Text("Paid").SemiBold();
                    row.AutoItem().Text(Amount(data.AmountPaid)).SemiBold();
                });
                Pair(col, "Payment", data.PaymentMethod);
                if (data.CashReceived is { } cash)
                {
                    Pair(col, "Cash received", Amount(cash));
                    Pair(col, "Change", Amount(data.ChangeGiven ?? 0));
                }

                if (data.Refunds.Count > 0)
                {
                    Divider(col);
                    col.Item().Text("Refunds").SemiBold();
                    foreach (var refund in data.Refunds)
                    {
                        Pair(col, refund.Date, "−" + Amount(refund.Amount));
                        col.Item().Text(refund.Reason).FontSize(7.5f).FontColor(Muted);
                    }
                }

                Divider(col);
                col.Item().AlignCenter().Text("Thank you for your visit!").Italic();
                col.Item().AlignCenter().Text("Servio").FontSize(7).FontColor(Muted);
            });
        });
    }

    private static void Pair(ColumnDescriptor col, string label, string value) =>
        col.Item().Row(row =>
        {
            row.RelativeItem().Text(label).FontColor(Muted);
            row.AutoItem().Text(value);
        });

    private static void Divider(ColumnDescriptor col) =>
        col.Item().PaddingVertical(4).LineHorizontal(0.6f).LineColor(Colors.Grey.Lighten1);
}
