using Servio.Model.Enums;

namespace Servio.Model.Responses;

public class RecommendationResponse
{
    public int MenuItemId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public CourseType CourseType { get; set; }
    public bool HasImage { get; set; }

    /// <summary>Final score between 0 and 1.</summary>
    public decimal Score { get; set; }

    /// <summary>Why the item is suggested, shown to the waiter.</summary>
    public string Reason { get; set; } = string.Empty;

    public double ContentScore { get; set; }
    public double HistoryScore { get; set; }
    public double AcceptanceScore { get; set; }
}
