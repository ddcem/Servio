using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

/// <summary>
/// Used by reference data that only has a name (table areas, item tags).
/// </summary>
public class NameUpsertRequest
{
    [Required(ErrorMessage = "Name is required.")]
    [StringLength(30, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 30 characters long.")]
    public string Name { get; set; } = string.Empty;
}
