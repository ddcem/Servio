using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class MenuCategorySearchObject : BaseSearchObject
{
    public int? PreparationStationId { get; set; }
    public CourseType? CourseType { get; set; }
}
