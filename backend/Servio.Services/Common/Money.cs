using System.Globalization;

namespace Servio.Services.Common;

public static class Money
{
    public static decimal Round(decimal amount) => Math.Round(amount, 2, MidpointRounding.AwayFromZero);

    public static decimal Percent(decimal amount, decimal percent) => Round(amount * percent / 100m);

    public static string Format(decimal amount, string symbol) => symbol + amount.ToString("#,##0.00", CultureInfo.InvariantCulture);
}
