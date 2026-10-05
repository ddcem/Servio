namespace Servio.Services.Database.Entities;

public class PasswordResetToken : IEntity
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string CodeHash { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime? UsedAt { get; set; }
    public int FailedAttempts { get; set; }

    public User User { get; set; } = null!;
}
