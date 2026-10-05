using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class ResetPasswordRequest
{
    [Required(ErrorMessage = "Email is required.")]
    [StringLength(100, ErrorMessage = "Email can be at most 100 characters long.")]
    [EmailAddress(ErrorMessage = ValidationRules.EmailMessage)]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Reset code is required.")]
    [RegularExpression(ValidationRules.ResetCodePattern, ErrorMessage = ValidationRules.ResetCodeMessage)]
    public string Code { get; set; } = string.Empty;

    [Required(ErrorMessage = "New password is required.")]
    [RegularExpression(ValidationRules.PasswordPattern, ErrorMessage = ValidationRules.PasswordMessage)]
    public string NewPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please repeat the new password.")]
    [Compare(nameof(NewPassword), ErrorMessage = ValidationRules.PasswordMismatchMessage)]
    public string NewPasswordConfirmation { get; set; } = string.Empty;
}
