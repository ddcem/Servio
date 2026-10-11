using System.Globalization;
using System.Reflection;
using System.Text.Json;
using System.Text.RegularExpressions;
using Servio.Model.Localization;

namespace Servio.Services.Localization;

/// <summary>
/// Translates the English texts of the API. English is the source language, so English texts are used
/// as they are and only other languages need a translation file (Localization/Translations/{code}.json,
/// mapping the English text to the translation). A missing translation falls back to English.
/// </summary>
public static partial class Translator
{
    private static readonly IReadOnlyDictionary<string, IReadOnlyDictionary<string, string>> Dictionaries = Load();

    /// <summary>Translates a fixed text into <paramref name="language"/> (default: the current request's language).</summary>
    public static string T(string text, string? language = null)
    {
        var lang = language ?? LanguageContext.Current;
        return lang != Languages.English && Dictionaries.TryGetValue(lang, out var dictionary) &&
               dictionary.TryGetValue(text, out var translated)
            ? translated
            : text;
    }

    /// <summary>Translates a template and its translatable arguments, then fills the placeholders.</summary>
    public static string Render(LocalizedText text, string? language = null)
    {
        var lang = language ?? LanguageContext.Current;
        var format = T(text.Format, lang);
        if (text.Args.Count == 0)
        {
            return format;
        }

        var args = text.Args.Select(arg => arg switch
        {
            Enum value => EnumText(value, lang),
            Localized word => T(word.Text, lang),
            LocalizedText nested => Render(nested, lang),
            LocalizedMoney money => Common.Money.Format(money.Amount, money.Symbol, lang),
            _ => arg
        }).ToArray();
        return string.Format(CultureInfo.InvariantCulture, format, args);
    }

    /// <summary>
    /// An enum value as a word inside a sentence: "PaymentStatus.PartiallyRefunded" → "partially refunded".
    /// Translations use the key "PaymentStatus.PartiallyRefunded".
    /// </summary>
    public static string EnumText(Enum value, string? language = null)
    {
        var key = $"{value.GetType().Name}.{value}";
        var translated = T(key, language);
        return translated != key ? translated : WordBoundary().Replace(value.ToString(), " $1").ToLowerInvariant();
    }

    private static Dictionary<string, IReadOnlyDictionary<string, string>> Load()
    {
        var assembly = typeof(Translator).Assembly;
        var result = new Dictionary<string, IReadOnlyDictionary<string, string>>();
        foreach (var language in Languages.Supported.Where(x => x != Languages.English))
        {
            using var stream = assembly.GetManifestResourceStream($"translations/{language}.json")
                ?? throw new InvalidOperationException($"The translation file for '{language}' is missing.");
            result[language] = JsonSerializer.Deserialize<Dictionary<string, string>>(stream)
                ?? throw new InvalidOperationException($"The translation file for '{language}' is empty.");
        }

        return result;
    }

    [GeneratedRegex("(?<=[a-z])([A-Z])")]
    private static partial Regex WordBoundary();
}
