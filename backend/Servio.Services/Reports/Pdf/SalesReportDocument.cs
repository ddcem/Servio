using System.Globalization;
using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using Servio.Model.Responses;
using Servio.Services.Localization;

namespace Servio.Services.Reports.Pdf;

public class SalesReportDocument(SalesReportResponse report, string restaurantName, string generatedAt) : IDocument
{
    public void Compose(IDocumentContainer container)
    {
        var s = report.CurrencySymbol;
        string Amount(decimal value) => ReportLayout.Amount(value, s);

        container.Page(page => ReportLayout.Page(page, restaurantName, "Sales report", report.From, report.To, generatedAt, col =>
        {
            col.Item().Element(c => ReportLayout.Kpis(c,
                ("Revenue", Amount(report.Revenue)),
                ("Paid orders", report.OrderCount.ToString(CultureInfo.InvariantCulture)),
                ("Average bill", Amount(report.AverageBill)),
                ("Guests served", report.GuestCount.ToString(CultureInfo.InvariantCulture)),
                ("VAT (included)", Amount(report.TaxCollected)),
                ("Tips", Amount(report.Tips)),
                ("Refunds", Amount(report.Refunds)),
                ("Net revenue", Amount(report.NetRevenue))));

            ReportLayout.Section(col, "Best-selling items", c => ReportLayout.Table(c,
                ["Item", "Category", "Sold", "Revenue"],
                report.TopItems.Select(x => new[] { x.Name, x.CategoryName, x.Quantity.ToString(), Amount(x.Revenue) })));

            ReportLayout.Section(col, "Least-selling items", c => ReportLayout.Table(c,
                ["Item", "Category", "Sold", "Revenue"],
                report.LeastSoldItems.Select(x => new[] { x.Name, x.CategoryName, x.Quantity.ToString(), Amount(x.Revenue) })));

            ReportLayout.Section(col, "Sales by category", c => ReportLayout.Table(c,
                ["Category", "Items sold", "Revenue"],
                report.Categories.Select(x => new[] { x.CategoryName, x.Quantity.ToString(), Amount(x.Revenue) })));

            ReportLayout.Section(col, "Payments by method", c => ReportLayout.Table(c,
                ["Method", "Payments", "Amount (incl. tips)"],
                report.PaymentMethods.Select(x => new[] { Translator.T(x.PaymentMethod), x.PaymentCount.ToString(), Amount(x.Amount) })));

            ReportLayout.Section(col, "Daily revenue", c => ReportLayout.Table(c,
                ["Date", "Orders", "Revenue"],
                report.Daily.Select(x => new[] { ReportLayout.Day(x.Date), x.OrderCount.ToString(), Amount(x.Revenue) })));
        }));
    }
}
