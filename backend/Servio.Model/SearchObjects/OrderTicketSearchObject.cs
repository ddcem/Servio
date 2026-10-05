using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class OrderTicketSearchObject : BaseSearchObject
{
    public int? StationId { get; set; }
    public int? OrderId { get; set; }
    public TicketStatus? Status { get; set; }

    /// <summary>Only tickets that still need work at the station (New and Preparing).</summary>
    public bool ActiveOnly { get; set; }
}
