using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class RefundRequest
{
    [Required(ErrorMessage = "Refund amount is required.")]
    [Range(typeof(decimal), "0.01", "100000", ErrorMessage = "Refund amount must be between 0.01 and the amount that is still refundable.")]
    public decimal? Amount { get; set; }

    [Required(ErrorMessage = "Please enter a reason for the refund.")]
    [StringLength(500, MinimumLength = 3, ErrorMessage = "Reason must be between 3 and 500 characters long.")]
    public string Reason { get; set; } = string.Empty;
}
