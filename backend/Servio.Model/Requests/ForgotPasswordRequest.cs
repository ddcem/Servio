using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class ForgotPasswordRequest
{
    [Required(ErrorMessage = "Email is required.")]
    [StringLength(100, ErrorMessage = "Email can be at most 100 characters long.")]
    [EmailAddress(ErrorMessage = ValidationRules.EmailMessage)]
    public string Email { get; set; } = string.Empty;
}
