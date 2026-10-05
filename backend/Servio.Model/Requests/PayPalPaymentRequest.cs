using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class PayPalPaymentRequest
{
    [Required(ErrorMessage = "Order is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose an order.")]
    public int? OrderId { get; set; }

    [Required(ErrorMessage = TipOptions.InvalidTipMessage)]
    [AllowedValues(0, 10, 15, 20, 25, ErrorMessage = TipOptions.InvalidTipMessage)]
    public int? TipPercent { get; set; }
}
