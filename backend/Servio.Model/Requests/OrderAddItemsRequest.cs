using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class OrderAddItemsRequest
{
    [Required(ErrorMessage = "Add at least one item to the order.")]
    [MinLength(1, ErrorMessage = "Add at least one item to the order.")]
    [MaxLength(100, ErrorMessage = "An order round can have at most 100 lines.")]
    public List<OrderItemRequest> Items { get; set; } = [];

    /// <summary>Suggestions shown while this round was built; stored as recommender feedback.</summary>
    [MaxLength(50, ErrorMessage = "At most 50 shown suggestions can be sent with one round.")]
    public List<ShownRecommendationRequest> ShownRecommendations { get; set; } = [];
}
