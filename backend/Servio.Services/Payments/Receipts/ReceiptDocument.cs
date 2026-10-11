using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Servio.Model.Localization;
using Servio.Services.Common;
using Servio.Services.Localization;

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
/// The guest's bill on an 80 mm receipt roll, in the request's language. Prices include VAT, so the VAT is shown as the part of
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
                col.Item().AlignCenter().Text(Translator.T("RECEIPT")).FontSize(9).LetterSpacing(0.2f).FontColor(Muted);
                Divider(col);

                Pair(col, Translator.T("Order"), data.OrderNumber);
                Pair(col, Translator.T("Table"), data.TableNumber.ToString());
                Pair(col, Translator.T("Waiter"), data.WaiterName);
                Pair(col, Translator.T("Date"), data.PaidAt);
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
                        header.Cell().Text(Translator.T("Item")).SemiBold();
                        header.Cell().AlignRight().Text(Translator.T("Qty × price")).SemiBold();
                        header.Cell().AlignRight().Text(Translator.T("Amount")).SemiBold();
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
                    row.RelativeItem().Text(Translator.T("TOTAL")).FontSize(12).Bold();
                    row.AutoItem().Text(Amount(data.Total)).FontSize(12).Bold();
                });
                col.Item().PaddingTop(4).Text(Translator.Render(new LocalizedText("VAT {0:0.##}% included in prices", data.TaxRate))).FontSize(7.5f).FontColor(Muted);
                Pair(col, Translator.T("Base (excl. VAT)"), Amount(data.Total - data.TaxAmount));
                Pair(col, Translator.Render(new LocalizedText("VAT {0:0.##}%", data.TaxRate)), Amount(data.TaxAmount));
                Divider(col);

                if (data.TipAmount > 0)
                {
                    Pair(col, Translator.Render(new LocalizedText("Tip ({0:0.##}%)", data.TipPercent)), Amount(data.TipAmount));
                }
                col.Item().Row(row =>
                {
                    row.RelativeItem().Text(Translator.T("Paid")).SemiBold();
                    row.AutoItem().Text(Amount(data.AmountPaid)).SemiBold();
                });
                Pair(col, Translator.T("Payment"), Translator.T(data.PaymentMethod));
                if (data.CashReceived is { } cash)
                {
                    Pair(col, Translator.T("Cash received"), Amount(cash));
                    Pair(col, Translator.T("Change"), Amount(data.ChangeGiven ?? 0));
                }

                if (data.Refunds.Count > 0)
                {
                    Divider(col);
                    col.Item().Text(Translator.T("Refunds")).SemiBold();
                    foreach (var refund in data.Refunds)
                    {
                        Pair(col, refund.Date, "−" + Amount(refund.Amount));
                        col.Item().Text(refund.Reason).FontSize(7.5f).FontColor(Muted);
                    }
                }

                Divider(col);
                col.Item().AlignCenter().Text(Translator.T("Thank you for your visit!")).Italic();
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
