using System.Globalization;
using System.Text;

namespace Servio.Services.Database.Seed;

/// <summary>
/// Menu icons embedded in this assembly (Noto Emoji, Apache License 2.0), named after the item, e.g. ribeye-steak.png.
/// </summary>
public static class SeedImages
{
    public const string ContentType = "image/png";

    public static byte[] ForMenuItem(string itemName)
    {
        var resourceName = $"seed-images/{Slug(itemName)}.png";
        using var stream = typeof(SeedImages).Assembly.GetManifestResourceStream(resourceName)
                           ?? throw new InvalidOperationException($"Seed image '{resourceName}' is missing.");
        using var memory = new MemoryStream();
        stream.CopyTo(memory);
        return memory.ToArray();
    }

    /// <summary>"Ćevapi" → "cevapi", "Ribeye Steak" → "ribeye-steak".</summary>
    private static string Slug(string name)
    {
        var withoutDiacritics = new string(name.Normalize(NormalizationForm.FormD)
            .Where(c => CharUnicodeInfo.GetUnicodeCategory(c) != UnicodeCategory.NonSpacingMark)
            .ToArray());
        return withoutDiacritics.ToLowerInvariant().Replace(' ', '-');
    }
}
