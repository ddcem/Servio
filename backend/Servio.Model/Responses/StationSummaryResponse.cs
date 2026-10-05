namespace Servio.Model.Responses;

/// <summary>
/// Current workload of a station, shown on the admin's view-only displays.
/// </summary>
public class StationSummaryResponse
{
    public int StationId { get; set; }
    public string StationName { get; set; } = string.Empty;
    public int NewCount { get; set; }
    public int PreparingCount { get; set; }
    public DateTime? OldestWaitingSince { get; set; }

    /// <summary>Average minutes from ticket creation to ready, for tickets finished today.</summary>
    public double? AverageMinutesToReadyToday { get; set; }
    public int CompletedToday { get; set; }
}
