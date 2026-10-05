using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class ReservationSearchObject : BaseSearchObject
{
    public int? TableId { get; set; }
    public ReservationStatus? Status { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}
