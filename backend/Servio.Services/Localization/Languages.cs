namespace Servio.Services.Localization;

/// <summary>The languages Servio speaks, as two-letter codes. English is the default and the source language.</summary>
public static class Languages
{
    public const string English = "en";
    public const string Bosnian = "bs";

    public static readonly IReadOnlyList<string> Supported = [English, Bosnian];

    /// <summary>"bs-BA", "BS" or "hr" → "bs"; anything unknown → English.</summary>
    public static string Normalize(string? code)
    {
        var language = code?.Trim().Split('-', '_')[0].ToLowerInvariant();
        return language switch
        {
            Bosnian or "hr" or "sr" => Bosnian,
            _ => English
        };
    }
}

/// <summary>
/// The language of the current request (from the app's Accept-Language header), or one chosen for a
/// block of work such as writing a notification in its recipient's language.
/// </summary>
public static class LanguageContext
{
    private static readonly AsyncLocal<string?> CurrentLanguage = new();

    public static string Current => CurrentLanguage.Value ?? Languages.English;

    public static void Set(string language) => CurrentLanguage.Value = Languages.Normalize(language);

    /// <summary>Switches the language until the returned scope is disposed.</summary>
    public static IDisposable Use(string language)
    {
        var previous = CurrentLanguage.Value;
        CurrentLanguage.Value = Languages.Normalize(language);
        return new Scope(() => CurrentLanguage.Value = previous);
    }

    private sealed class Scope(Action restore) : IDisposable
    {
        public void Dispose() => restore();
    }
}
