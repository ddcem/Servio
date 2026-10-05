namespace Servio.Services.Database.Entities;

public class ItemTag
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public ICollection<MenuItem> MenuItems { get; set; } = [];
}
