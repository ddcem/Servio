namespace Servio.Services.Database.Entities;

public class RecommendationEvent : IEntity
{
    public int Id { get; set; }
    public int OrderId { get; set; }
    public int WaiterId { get; set; }
    public int SourceMenuItemId { get; set; }
    public int RecommendedMenuItemId { get; set; }
    public decimal Score { get; set; }
    public string Reason { get; set; } = string.Empty;
    public bool WasAccepted { get; set; }
    public DateTime CreatedAt { get; set; }

    public Order Order { get; set; } = null!;
    public User Waiter { get; set; } = null!;
    public MenuItem SourceMenuItem { get; set; } = null!;
    public MenuItem RecommendedMenuItem { get; set; } = null!;
}
