using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class OrderItemRequest
{
    [Required(ErrorMessage = "Menu item is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a menu item.")]
    public int? MenuItemId { get; set; }

    [Required(ErrorMessage = "Quantity is required.")]
    [Range(1, 50, ErrorMessage = "Quantity must be between 1 and 50.")]
    public int? Quantity { get; set; }

    [StringLength(200, ErrorMessage = "Note can be at most 200 characters long.")]
    public string? Note { get; set; }
}
