using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class OrderCreateRequest : OrderAddItemsRequest
{
    [Required(ErrorMessage = "Table is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a table.")]
    public int? TableId { get; set; }

    [Required(ErrorMessage = "Number of guests is required.")]
    [Range(1, 20, ErrorMessage = "Number of guests must be between 1 and 20.")]
    public int? GuestCount { get; set; }
}
