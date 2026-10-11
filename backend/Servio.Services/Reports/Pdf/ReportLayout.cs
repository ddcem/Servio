using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Servio.Services.Localization;

namespace Servio.Services.Reports.Pdf;

/// <summary>
/// Shared look of the printable reports: header, KPI tiles, tables and footer. Titles, labels and column
/// headers are passed in English and translated into the request's language here.
/// </summary>
internal static class ReportLayout
{
    public const string Primary = "#1E3A8A";
    public const string Muted = "#6B7280";
    public const string Border = "#E5E7EB";
    public const string Zebra = "#F9FAFB";

    public static void Page(PageDescriptor page, string restaurantName, string title, DateOnly from, DateOnly to,
        string generatedAt, Action<ColumnDescriptor> content)
    {
        page.Size(PageSizes.A4);
        page.Margin(36);
        page.DefaultTextStyle(x => x.FontSize(10).FontColor("#111827"));

        page.Header().PaddingBottom(14).Row(row =>
        {
            row.RelativeItem().Column(col =>
            {
                col.Item().Text(restaurantName).FontSize(11).FontColor(Muted);
                col.Item().Text(Translator.T(title)).FontSize(20).Bold().FontColor(Primary);
                col.Item().Text($"{from:dd.MM.yyyy} – {to:dd.MM.yyyy}").FontColor(Muted);
            });
            row.ConstantItem(150).AlignRight().AlignBottom().Text(Translator.Render(new Model.Localization.LocalizedText("Generated {0}", generatedAt))).FontSize(8).FontColor(Muted);
        });

        page.Content().Column(col =>
        {
            col.Spacing(16);
            content(col);
        });

        page.Footer().AlignCenter().Text(text =>
        {
            text.DefaultTextStyle(x => x.FontSize(8).FontColor(Muted));
            text.Span(Translator.T("Servio · page "));
            text.CurrentPageNumber();
            text.Span(Translator.T(" of "));
            text.TotalPages();
        });
    }

    public static void Kpis(IContainer container, params (string Label, string Value)[] kpis) =>
        container.Table(table =>
        {
            table.ColumnsDefinition(columns =>
            {
                for (var i = 0; i < Math.Min(kpis.Length, 4); i++)
                {
                    columns.RelativeColumn();
                }
            });

            foreach (var (label, value) in kpis)
            {
                table.Cell().Padding(3).Border(1).BorderColor(Border).Background(Zebra).Padding(8).Column(col =>
                {
                    col.Item().Text(Translator.T(label)).FontSize(8).FontColor(Muted);
                    col.Item().Text(value).FontSize(14).Bold();
                });
            }
        });

    public static void Section(ColumnDescriptor column, string title, Action<IContainer> content)
    {
        // Keeps a heading together with the first rows of its table instead of stranding it at a page end.
        column.Item().EnsureSpace(90).Column(col =>
        {
            col.Item().PaddingBottom(6).Text(Translator.T(title)).FontSize(13).SemiBold().FontColor(Primary);
            content(col.Item());
        });
    }

    /// <summary>A simple table: first column left-aligned, the rest right-aligned (numbers).</summary>
    public static void Table(IContainer container, string[] headers, IEnumerable<string[]> rows, float firstColumnWeight = 3)
    {
        container.Table(table =>
        {
            table.ColumnsDefinition(columns =>
            {
                columns.RelativeColumn(firstColumnWeight);
                for (var i = 1; i < headers.Length; i++)
                {
                    columns.RelativeColumn();
                }
            });

            table.Header(header =>
            {
                for (var i = 0; i < headers.Length; i++)
                {
                    var cell = header.Cell().BorderBottom(1).BorderColor(Primary).PaddingVertical(4).PaddingHorizontal(4);
                    (i == 0 ? cell : cell.AlignRight()).Text(Translator.T(headers[i])).SemiBold().FontSize(9);
                }
            });

            var index = 0;
            foreach (var row in rows)
            {
                var background = index++ % 2 == 0 ? "#FFFFFF" : Zebra;
                for (var i = 0; i < row.Length; i++)
                {
                    var cell = table.Cell().Background(background).BorderBottom(1).BorderColor(Border).PaddingVertical(3).PaddingHorizontal(4);
                    (i == 0 ? cell : cell.AlignRight()).Text(row[i]).FontSize(9);
                }
            }
        });
    }

    public static string Amount(decimal value, string symbol) => Common.Money.Format(value, symbol);

    public static string Percent(double? value) => value is null ? "–" : $"{value * 100:0}%";

    /// <summary>"Mon, 05.10.2026" with the day name in the request's language.</summary>
    public static string Day(DateOnly date) =>
        $"{Translator.T(date.DayOfWeek.ToString()[..3])}, {date.ToString("dd.MM.yyyy", System.Globalization.CultureInfo.InvariantCulture)}";
}
