using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class MenuItemUpsertRequest
{
    [Required(ErrorMessage = "Name is required.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 100 characters long.")]
    public string Name { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Description can be at most 500 characters long.")]
    public string? Description { get; set; }

    [Required(ErrorMessage = "Price is required.")]
    [Range(typeof(decimal), "0.01", "10000", ErrorMessage = "Price must be between 0.01 and 10000.00.")]
    public decimal? Price { get; set; }

    [Required(ErrorMessage = "Category is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a category from the list.")]
    public int? CategoryId { get; set; }

    public bool IsAvailableToday { get; set; } = true;

    [MaxLength(10, ErrorMessage = "An item can have at most 10 tags.")]
    public List<int> TagIds { get; set; } = [];
}
