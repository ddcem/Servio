using Servio.Model.Configuration;

namespace Servio.Worker.Configuration;

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

    /// <summary>
    /// The single place where the worker turns .env values into typed options.
    /// </summary>
    public static IServiceCollection AddWorkerOptions(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<RabbitMqOptions>(o =>
        {
            o.Host = configuration.GetRequired(EnvKeys.RabbitMqHost);
            o.Port = configuration.GetRequiredInt(EnvKeys.RabbitMqPort);
            o.Username = configuration.GetRequired(EnvKeys.RabbitMqUser);
            o.Password = configuration.GetRequired(EnvKeys.RabbitMqPassword);
            o.EmailQueue = configuration.GetRequired(EnvKeys.RabbitMqEmailQueue);
        });

        services.Configure<SmtpOptions>(o =>
        {
            o.Host = configuration.GetRequired(EnvKeys.SmtpHost);
            o.Port = configuration.GetRequiredInt(EnvKeys.SmtpPort);
            o.Username = configuration.GetRequired(EnvKeys.SmtpUsername);
            o.Password = configuration.GetRequired(EnvKeys.SmtpPassword);
            o.UseSsl = bool.Parse(configuration.GetRequired(EnvKeys.SmtpUseSsl));
            o.FromEmail = configuration.GetRequired(EnvKeys.SmtpFromEmail);
            o.FromName = configuration.GetRequired(EnvKeys.SmtpFromName);
        });

        return services;
    }
}
