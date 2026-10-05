using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class MenuItemSearchObject : BaseSearchObject
{
    public int? CategoryId { get; set; }
    public int? PreparationStationId { get; set; }
    public CourseType? CourseType { get; set; }
    public int? TagId { get; set; }
    public bool? IsAvailableToday { get; set; }
    public decimal? MinPrice { get; set; }
    public decimal? MaxPrice { get; set; }
    public bool FavoritesOnly { get; set; }
    public bool NewestFirst { get; set; }
}
