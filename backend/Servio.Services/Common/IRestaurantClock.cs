namespace Servio.Services.Common;

/// <summary>
/// All timestamps are stored in UTC; this converts them to the restaurant's local time
/// where a business day or a human-readable time is needed.
/// </summary>
public interface IRestaurantClock
{
    DateTime UtcNow { get; }
    DateTime ToLocal(DateTime utc);

    /// <summary>Converts a local wall-clock time of the restaurant to UTC.</summary>
    DateTime ToUtc(DateTime local);

    /// <summary>UTC instant of today's local midnight, the start of the business day.</summary>
    DateTime TodayStartUtc { get; }

    string FormatLocal(DateTime utc, string format = "dd.MM.yyyy HH:mm");
}
