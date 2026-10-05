namespace Servio.Model.Responses;

public class StaffReportResponse
{
    public DateOnly From { get; set; }
    public DateOnly To { get; set; }
    public string CurrencySymbol { get; set; } = string.Empty;
    public List<WaiterPerformanceResponse> Waiters { get; set; } = [];
    public List<StationPerformanceResponse> Stations { get; set; } = [];
}

public class WaiterPerformanceResponse
{
    public int UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public int OrderCount { get; set; }
    public int GuestCount { get; set; }
    public decimal Revenue { get; set; }
    public decimal AverageBill { get; set; }
    public decimal Tips { get; set; }

    /// <summary>Upselling suggestions shown to this waiter and how many guests accepted.</summary>
    public int SuggestionsShown { get; set; }
    public int SuggestionsAccepted { get; set; }
    public double? SuggestionAcceptanceRate { get; set; }
}

public class StationPerformanceResponse
{
    public string StationName { get; set; } = string.Empty;
    public int TicketCount { get; set; }
    public double? AverageMinutesToStart { get; set; }
    public double? AverageMinutesToReady { get; set; }
}
