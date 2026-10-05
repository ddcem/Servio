using Microsoft.Extensions.Options;
using Servio.Services.Configuration;

namespace Servio.Services.Common;

public class RestaurantClock(IOptions<RestaurantOptions> options) : IRestaurantClock
{
    private readonly TimeZoneInfo _timeZone = TimeZoneInfo.FindSystemTimeZoneById(options.Value.TimeZoneId);

    public DateTime UtcNow => DateTime.UtcNow;

    public DateTime ToLocal(DateTime utc) =>
        TimeZoneInfo.ConvertTimeFromUtc(DateTime.SpecifyKind(utc, DateTimeKind.Utc), _timeZone);

    public DateTime ToUtc(DateTime local) =>
        TimeZoneInfo.ConvertTimeToUtc(DateTime.SpecifyKind(local, DateTimeKind.Unspecified), _timeZone);

    public DateTime TodayStartUtc => ToUtc(ToLocal(UtcNow).Date);

    public string FormatLocal(DateTime utc, string format = "dd.MM.yyyy HH:mm") => ToLocal(utc).ToString(format);
}
