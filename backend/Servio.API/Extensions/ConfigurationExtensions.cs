using Servio.Model.Configuration;

namespace Servio.API.Extensions;

public static class ConfigurationExtensions
{
    public static string GetRequired(this IConfiguration configuration, string key) =>
        configuration[key] is { Length: > 0 } value
            ? value
            : throw new InvalidOperationException($"Missing required configuration value '{key}'. Check your .env file.");

    public static int GetRequiredInt(this IConfiguration configuration, string key) =>
        int.TryParse(configuration.GetRequired(key), out var value)
            ? value
            : throw new InvalidOperationException($"Configuration value '{key}' must be a whole number.");

    public static string GetConnectionString(this IConfiguration configuration) =>
        $"Host={configuration.GetRequired(EnvKeys.DbHost)};" +
        $"Port={configuration.GetRequired(EnvKeys.DbPort)};" +
        $"Database={configuration.GetRequired(EnvKeys.DbName)};" +
        $"Username={configuration.GetRequired(EnvKeys.DbUser)};" +
        $"Password={configuration.GetRequired(EnvKeys.DbPassword)};" +
        "Gss Encryption Mode=Disable";
}
