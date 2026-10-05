using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

/// <summary>
/// Body of every cancel action: the reason is stored in the audit trail.
/// </summary>
public class ReasonRequest
{
    [Required(ErrorMessage = "Please enter a reason.")]
    [StringLength(500, MinimumLength = 3, ErrorMessage = "Reason must be between 3 and 500 characters long.")]
    public string Reason { get; set; } = string.Empty;
}
