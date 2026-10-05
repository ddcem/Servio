using System.ComponentModel.DataAnnotations;
using Servio.Model.Constants;

namespace Servio.Model.Requests;

public class CurrencyUpsertRequest
{
    [Required(ErrorMessage = "Currency code is required.")]
    [RegularExpression(ValidationRules.CurrencyCodePattern, ErrorMessage = ValidationRules.CurrencyCodeMessage)]
    public string Code { get; set; } = string.Empty;

    [Required(ErrorMessage = "Name is required.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "Name must be between 2 and 50 characters long.")]
    public string Name { get; set; } = string.Empty;

    [Required(ErrorMessage = "Symbol is required.")]
    [StringLength(5, ErrorMessage = "Symbol can be at most 5 characters long, e.g. €.")]
    public string Symbol { get; set; } = string.Empty;
}
