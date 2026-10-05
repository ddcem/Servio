using Servio.Model.Enums;

namespace Servio.Services.Recommendations;

public enum PriceTier
{
    Budget = 0,
    Standard = 1,
    Premium = 2
}

/// <summary>
/// A menu item as the recommender sees it: its attributes and the feature vector built from them.
/// </summary>
public class MenuItemFeatures
{
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
    public string CategoryName { get; init; } = string.Empty;
    public CourseType CourseType { get; init; }
    public bool HasImage { get; init; }
    public bool IsAvailableToday { get; init; }
    public PriceTier PriceTier { get; init; }
    public IReadOnlyList<string> Tags { get; init; } = [];

    /// <summary>[course type one-hot | price tier one-hot | tag one-hot].</summary>
    public double[] Vector { get; init; } = [];
}
