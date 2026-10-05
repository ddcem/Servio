using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

/// <summary>
/// Admin edit of an employee. The password fields are optional and only validated when a new password is entered.
/// </summary>
public class UserUpdateRequest
{
    [Required(ErrorMessage = "First name is required.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "First name must be between 2 and 50 characters long.")]
    public string FirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Last name is required.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "Last name must be between 2 and 50 characters long.")]
    public string LastName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Username is required.")]
    [RegularExpression(ValidationRules.UsernamePattern, ErrorMessage = ValidationRules.UsernameMessage)]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email is required.")]
    [StringLength(100, ErrorMessage = "Email can be at most 100 characters long.")]
    [EmailAddress(ErrorMessage = ValidationRules.EmailMessage)]
    public string Email { get; set; } = string.Empty;

    [RegularExpression(ValidationRules.PhonePattern, ErrorMessage = ValidationRules.PhoneMessage)]
    public string? PhoneNumber { get; set; }

    [Required(ErrorMessage = "Role is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a role from the list.")]
    public int? RoleId { get; set; }

    public bool IsActive { get; set; } = true;

    [RegularExpression(ValidationRules.PasswordPattern, ErrorMessage = ValidationRules.PasswordMessage)]
    public string? NewPassword { get; set; }

    [Compare(nameof(NewPassword), ErrorMessage = ValidationRules.PasswordMismatchMessage)]
    public string? NewPasswordConfirmation { get; set; }
}
