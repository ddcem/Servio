using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class RecommendationRequest
{
    /// <summary>The item the waiter just added; suggestions are built around it.</summary>
    [Required(ErrorMessage = "Menu item is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a menu item.")]
    public int? SourceMenuItemId { get; set; }

    /// <summary>Everything already in the cart and on the open order, so it is not suggested again.</summary>
    [MaxLength(200, ErrorMessage = "The cart can contain at most 200 items.")]
    public List<int> CartMenuItemIds { get; set; } = [];

    [Range(1, 5, ErrorMessage = "Between 1 and 5 suggestions can be requested.")]
    public int Take { get; set; } = 3;
}
