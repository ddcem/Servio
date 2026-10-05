namespace Servio.Services.Database.Entities;

public class MenuItem
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public byte[]? Image { get; set; }
    public string? ImageContentType { get; set; }
    public bool IsAvailableToday { get; set; } = true;
    public bool IsDeleted { get; set; }
    public DateTime CreatedAt { get; set; }

    public MenuCategory Category { get; set; } = null!;
    public ICollection<ItemTag> Tags { get; set; } = [];
    public ICollection<User> FavoritedBy { get; set; } = [];
}
