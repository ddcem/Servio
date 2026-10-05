using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class OrderSearchObject : BaseSearchObject
{
    public int? TableId { get; set; }
    public int? WaiterId { get; set; }
    public OrderStatus? Status { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
    public bool MyOrdersOnly { get; set; }
}
