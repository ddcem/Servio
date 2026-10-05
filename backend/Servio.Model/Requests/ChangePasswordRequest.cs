using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class ChangePasswordRequest
{
    [Required(ErrorMessage = "Current password is required.")]
    [StringLength(100, ErrorMessage = "Password can be at most 100 characters long.")]
    public string CurrentPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "New password is required.")]
    [RegularExpression(ValidationRules.PasswordPattern, ErrorMessage = ValidationRules.PasswordMessage)]
    public string NewPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please repeat the new password.")]
    [Compare(nameof(NewPassword), ErrorMessage = ValidationRules.PasswordMismatchMessage)]
    public string NewPasswordConfirmation { get; set; } = string.Empty;
}
