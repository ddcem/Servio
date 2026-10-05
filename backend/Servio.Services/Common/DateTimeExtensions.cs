namespace Servio.Services.Common;

public static class DateTimeExtensions
{
    /// <summary>
    /// Normalises client-supplied times to UTC. Values without an offset are treated as UTC,
    /// because the clients always send UTC.
    /// </summary>
    public static DateTime AsUtc(this DateTime value) => value.Kind switch
    {
        DateTimeKind.Utc => value,
        DateTimeKind.Local => value.ToUniversalTime(),
        _ => DateTime.SpecifyKind(value, DateTimeKind.Utc)
    };

    public static DateTime? AsUtc(this DateTime? value) => value?.AsUtc();
}
