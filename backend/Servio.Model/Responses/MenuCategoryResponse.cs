using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class MenuCategoryResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public CourseType CourseType { get; set; }
    public int PreparationStationId { get; set; }
    public string PreparationStationName { get; set; } = string.Empty;
    public int SortOrder { get; set; }

    /// <summary>A category with menu items (including removed ones kept for order history) cannot be deleted.</summary>
    public int MenuItemCount { get; set; }
}
