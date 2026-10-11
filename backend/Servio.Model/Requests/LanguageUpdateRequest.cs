using System.ComponentModel.DataAnnotations;

namespace Servio.Model.Requests;

public class LanguageUpdateRequest
{
    [Required(ErrorMessage = "Language is required.")]
    [AllowedValues("en", "bs", ErrorMessage = "Choose English (en) or Bosnian (bs).")]
    public string? Language { get; set; }
}
