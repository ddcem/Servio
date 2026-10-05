namespace Servio.Services.Database.Entities;

public class UserSession
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string TokenJti { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime? RevokedAt { get; set; }

    public User User { get; set; } = null!;
}
