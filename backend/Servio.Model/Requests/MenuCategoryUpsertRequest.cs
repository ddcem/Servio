using System.ComponentModel.DataAnnotations;
using Servio.Model.Enums;

namespace Servio.Model.Requests;

public class MenuCategoryUpsertRequest
{
    [Required(ErrorMessage = "Name is required.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 50 characters long.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Course type is required.")]
    [EnumDataType(typeof(CourseType), ErrorMessage = "Choose a course type from the list.")]
    public CourseType? CourseType { get; set; }

    [Required(ErrorMessage = "Preparation station is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a preparation station from the list.")]
    public int? PreparationStationId { get; set; }

    [Range(0, 999, ErrorMessage = "Sort order must be a whole number between 0 and 999.")]
    public int SortOrder { get; set; }
}
