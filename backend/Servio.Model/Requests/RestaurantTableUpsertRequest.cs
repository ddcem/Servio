using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class RestaurantTableUpsertRequest
{
    [Required(ErrorMessage = "Table number is required.")]
    [Range(1, 999, ErrorMessage = "Table number must be a whole number between 1 and 999.")]
    public int? Number { get; set; }

    [Required(ErrorMessage = "Capacity is required.")]
    [Range(1, 20, ErrorMessage = "Capacity must be between 1 and 20 seats.")]
    public int? Capacity { get; set; }

    [Required(ErrorMessage = "Area is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose an area from the list.")]
    public int? AreaId { get; set; }

    public bool IsActive { get; set; } = true;
}
