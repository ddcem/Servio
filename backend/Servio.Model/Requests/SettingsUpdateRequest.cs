using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class SettingsUpdateRequest
{
    [Required(ErrorMessage = "Restaurant name is required.")]
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Restaurant name must be between 2 and 100 characters long.")]
    public string RestaurantName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Currency is required.")]
    [Range(1, int.MaxValue, ErrorMessage = "Choose a currency from the list.")]
    public int? CurrencyId { get; set; }

    [Required(ErrorMessage = "Tax rate is required.")]
    [Range(typeof(decimal), "0", "100", ErrorMessage = "Tax rate must be a percentage between 0 and 100, e.g. 17.")]
    public decimal? TaxRate { get; set; }
}
