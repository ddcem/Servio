using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class LoginRequest
{
    [Required(ErrorMessage = "Username is required.")]
    [StringLength(50, ErrorMessage = "Username can be at most 50 characters long.")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Password is required.")]
    [StringLength(100, ErrorMessage = "Password can be at most 100 characters long.")]
    public string Password { get; set; } = string.Empty;
}
