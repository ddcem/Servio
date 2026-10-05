using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class ReservationUpsertRequest
{
    [Required(ErrorMessage = "Table is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a table from the list.")]
    public int? TableId { get; set; }

    [Required(ErrorMessage = "Guest name is required.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Guest name must be between 2 and 100 characters long.")]
    public string GuestName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Guest phone is required.")]
    [RegularExpression(ValidationRules.PhonePattern, ErrorMessage = ValidationRules.PhoneMessage)]
    public string GuestPhone { get; set; } = string.Empty;

    [StringLength(100, ErrorMessage = "Email can be at most 100 characters long.")]
    [EmailAddress(ErrorMessage = ValidationRules.EmailMessage)]
    public string? GuestEmail { get; set; }

    [Required(ErrorMessage = "Party size is required.")]
    [Range(1, 20, ErrorMessage = "Party size must be between 1 and 20 guests.")]
    public int? PartySize { get; set; }

    [Required(ErrorMessage = "Start time is required.")]
    public DateTime? StartTime { get; set; }

    [Required(ErrorMessage = "End time is required.")]
    public DateTime? EndTime { get; set; }

    [StringLength(500, ErrorMessage = "Note can be at most 500 characters long.")]
    public string? Note { get; set; }
}
