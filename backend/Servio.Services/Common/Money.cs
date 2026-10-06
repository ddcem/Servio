using System.Globalization;

namespace Servio.Services.Common;

public static class Money
{
    public static decimal Round(decimal amount) => Math.Round(amount, 2, MidpointRounding.AwayFromZero);

    public static decimal Percent(decimal amount, decimal percent) => Round(amount * percent / 100m);

    /// <summary>The tax contained in a price that already includes it: 160.00 at 17% contains 23.25.</summary>
    public static decimal IncludedTax(decimal grossAmount, decimal percent) => Round(grossAmount * percent / (100m + percent));

    public static string Format(decimal amount, string symbol) => symbol + amount.ToString("#,##0.00", CultureInfo.InvariantCulture);
}
