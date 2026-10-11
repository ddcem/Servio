using System.Globalization;
using Servio.Services.Localization;

namespace Servio.Services.Common;

public static class Money
{
    private static readonly NumberFormatInfo BosnianNumbers = new() { NumberDecimalSeparator = ",", NumberGroupSeparator = "." };

    public static decimal Round(decimal amount) => Math.Round(amount, 2, MidpointRounding.AwayFromZero);

    public static decimal Percent(decimal amount, decimal percent) => Round(amount * percent / 100m);

    /// <summary>The tax contained in a price that already includes it: 160.00 at 17% contains 23.25.</summary>
    public static decimal IncludedTax(decimal grossAmount, decimal percent) => Round(grossAmount * percent / (100m + percent));

    /// <summary>"€1,234.50" in English, "1.234,50 €" in Bosnian (default: the current request's language).</summary>
    public static string Format(decimal amount, string symbol, string? language = null) =>
        (language ?? LanguageContext.Current) == Languages.Bosnian
            ? $"{amount.ToString("#,##0.00", BosnianNumbers)} {symbol}"
            : symbol + amount.ToString("#,##0.00", CultureInfo.InvariantCulture);
}
