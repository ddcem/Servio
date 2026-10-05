namespace Servio.Services.Reservations;

public static class ReservationRules
{
    public static readonly TimeSpan MinDuration = TimeSpan.FromMinutes(30);
    public static readonly TimeSpan MaxDuration = TimeSpan.FromHours(6);
    public static readonly TimeSpan MaxBookingAhead = TimeSpan.FromDays(180);

    /// <summary>Tolerance for a start time entered "now" that is a few minutes old by the time it is saved.</summary>
    public static readonly TimeSpan PastStartTolerance = TimeSpan.FromMinutes(5);

    /// <summary>Guests may be seated (reservation completed) at most this long before the start time.</summary>
    public static readonly TimeSpan CompleteEarliestBeforeStart = TimeSpan.FromMinutes(30);

    /// <summary>A guest counts as a no-show only after this grace period has passed since the start time.</summary>
    public static readonly TimeSpan NoShowGracePeriod = TimeSpan.FromMinutes(15);
}
