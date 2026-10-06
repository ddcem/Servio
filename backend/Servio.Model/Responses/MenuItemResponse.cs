using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class MenuItemResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal Price { get; set; }
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public CourseType CourseType { get; set; }
    public int PreparationStationId { get; set; }
    public string PreparationStationName { get; set; } = string.Empty;
    public bool IsAvailableToday { get; set; }
    public bool HasImage { get; set; }
    public bool IsFavorite { get; set; }

    /// <summary>How many of this item the logged-in waiter has sold, shown on the favorites cards.</summary>
    public int SoldByMeCount { get; set; }
    public List<LookupResponse> Tags { get; set; } = [];
}
