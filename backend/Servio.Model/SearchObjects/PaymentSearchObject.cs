using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class PaymentSearchObject : BaseSearchObject
{
    public int? OrderId { get; set; }
    public int? PaymentMethodId { get; set; }
    public PaymentStatus? Status { get; set; }
    public DateTime? From { get; set; }
    public DateTime? To { get; set; }
}
