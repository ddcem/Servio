namespace Servio.Services.Database.Entities;

public class TableArea
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    public ICollection<RestaurantTable> Tables { get; set; } = [];
}
