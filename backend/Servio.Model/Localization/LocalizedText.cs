using System.Globalization;

namespace Servio.Model.Localization;

/// <summary>
/// A sentence that is translated when it is shown: an English template with numbered placeholders
/// ("Table {0} seats at most {1} guests.") and its arguments. Arguments that are enums,
/// <see cref="Localized"/> words or other <see cref="LocalizedText"/>s are translated as well.
/// </summary>
public sealed class LocalizedText(string format, params object?[] args)
{
    public string Format { get; } = format;
    public IReadOnlyList<object?> Args { get; } = args;

    /// <summary>The English sentence, used for logs.</summary>
    public override string ToString() =>
        Args.Count == 0 ? Format : string.Format(CultureInfo.InvariantCulture, Format, Args.ToArray());

    public static implicit operator LocalizedText(string text) => new(text);
}

/// <summary>A fixed word inside a sentence that has a translation, e.g. a station name ("kitchen").</summary>
public sealed record Localized(string Text)
{
    public override string ToString() => Text;
}

/// <summary>An amount inside a sentence, formatted the way the reader's language writes money ("€47.00" / "47,00 €").</summary>
public sealed record LocalizedMoney(decimal Amount, string Symbol)
{
    public override string ToString() => Symbol + Amount.ToString("#,##0.00", CultureInfo.InvariantCulture);
}
