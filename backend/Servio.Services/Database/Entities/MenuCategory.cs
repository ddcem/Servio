using Servio.Model.Enums;

namespace Servio.Services.Database.Entities;

public class MenuCategory : IEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public CourseType CourseType { get; set; }
    public int PreparationStationId { get; set; }
    public int SortOrder { get; set; }

    public PreparationStation PreparationStation { get; set; } = null!;
    public ICollection<MenuItem> MenuItems { get; set; } = [];
}
