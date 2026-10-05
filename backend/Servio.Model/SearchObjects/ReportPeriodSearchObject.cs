using System.ComponentModel.DataAnnotations;

namespace Servio.Model.SearchObjects;

/// <summary>
/// A report period in the restaurant's local calendar, both days inclusive. Defaults to the last 30 days.
/// </summary>
public class ReportPeriodSearchObject : IValidatableObject
{
    public const int MaxDays = 366;

    public DateOnly? From { get; set; }
    public DateOnly? To { get; set; }

    public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
    {
        if (From is { } from && To is { } to)
        {
            if (from > to)
            {
                yield return new ValidationResult("The start date must be on or before the end date.", [nameof(From)]);
            }
            else if (to.DayNumber - from.DayNumber >= MaxDays)
            {
                yield return new ValidationResult($"A report can cover at most {MaxDays} days.", [nameof(To)]);
            }
        }
    }
}
