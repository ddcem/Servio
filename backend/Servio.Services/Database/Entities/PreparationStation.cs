namespace Servio.Services.Database.Entities;

public class PreparationStation
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public ICollection<MenuCategory> Categories { get; set; } = [];
}
