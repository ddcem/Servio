using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

/// <summary>
/// A suggestion the waiter saw while building this round. Whether it was accepted is decided
/// on the server: it was accepted if the suggested item is part of the round.
/// </summary>
public class ShownRecommendationRequest
{
    [Required(ErrorMessage = "Source item is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Source item is not valid.")]
    public int? SourceMenuItemId { get; set; }

    [Required(ErrorMessage = "Suggested item is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Suggested item is not valid.")]
    public int? RecommendedMenuItemId { get; set; }

    [Range(0, 1, ErrorMessage = "Score must be between 0 and 1.")]
    public decimal Score { get; set; }

    [Required(ErrorMessage = "Reason is required.")]
    [StringLength(200, ErrorMessage = "Reason can be at most 200 characters long.")]
    public string Reason { get; set; } = string.Empty;
}
