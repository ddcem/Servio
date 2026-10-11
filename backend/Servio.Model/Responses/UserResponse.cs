namespace Servio.Model.Responses;

public class UserResponse
{
    public int Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public int RoleId { get; set; }
    public string Role { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public bool HasProfileImage { get; set; }
    /// <summary>The app language the user chose: "en" or "bs".</summary>
    public string PreferredLanguage { get; set; } = "en";
    public DateTime CreatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }

    /// <summary>Users who took orders or managed reservations can only be deactivated, not deleted.</summary>
    public bool HasActivity { get; set; }
}
