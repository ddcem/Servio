using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using Servio.Model.Localization;
using Servio.Model.Responses;
using Servio.Services.Localization;

namespace Servio.Services.Reports.Pdf;

public class StaffReportDocument(StaffReportResponse report, string restaurantName, string generatedAt) : IDocument
{
    public void Compose(IDocumentContainer container)
    {
        var s = report.CurrencySymbol;
        string Amount(decimal value) => ReportLayout.Amount(value, s);
        string Minutes(double? value) => value is null ? "–" : Translator.Render(new LocalizedText("{0:0.0} min", value));

        container.Page(page => ReportLayout.Page(page, restaurantName, "Staff performance report", report.From, report.To, generatedAt, col =>
        {
            ReportLayout.Section(col, "Waiters", c => ReportLayout.Table(c,
                ["Waiter", "Orders", "Guests", "Revenue", "Average bill", "Tips"],
                report.Waiters.Select(x => new[]
                {
                    x.IsActive ? x.Name : Translator.Render(new LocalizedText("{0} (inactive)", x.Name)),
                    x.OrderCount.ToString(), x.GuestCount.ToString(), Amount(x.Revenue), Amount(x.AverageBill), Amount(x.Tips)
                }), firstColumnWeight: 2.2f));

            ReportLayout.Section(col, "Upselling suggestions", c => ReportLayout.Table(c,
                ["Waiter", "Shown", "Accepted", "Acceptance rate"],
                report.Waiters.Select(x => new[]
                {
                    x.Name, x.SuggestionsShown.ToString(), x.SuggestionsAccepted.ToString(), ReportLayout.Percent(x.SuggestionAcceptanceRate)
                }), firstColumnWeight: 2.2f));

            ReportLayout.Section(col, "Kitchen and bar", c => ReportLayout.Table(c,
                ["Station", "Tickets completed", "Avg. wait until started", "Avg. time until ready"],
                report.Stations.Select(x => new[]
                {
                    Translator.T(x.StationName), x.TicketCount.ToString(), Minutes(x.AverageMinutesToStart), Minutes(x.AverageMinutesToReady)
                }), firstColumnWeight: 1.5f));
        }));
    }
}
