using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class CashPaymentRequest
{
    [Required(ErrorMessage = "Order is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose an order.")]
    public int? OrderId { get; set; }

    [Required(ErrorMessage = TipOptions.InvalidTipMessage)]
    [AllowedValues(0, 10, 15, 20, 25, ErrorMessage = TipOptions.InvalidTipMessage)]
    public int? TipPercent { get; set; }

    [Required(ErrorMessage = "Enter the cash received from the guest.")]
    [Range(typeof(decimal), "0.01", "100000", ErrorMessage = "Cash received must be an amount between 0.01 and 100000.00.")]
    public decimal? CashReceived { get; set; }
}
