namespace Servio.Model.Configuration;

/// <summary>
/// Names of all environment variables read by the API and the worker (values live in .env).
/// </summary>
public static class EnvKeys
{
    public const string DbHost = "DB_HOST";
    public const string DbPort = "DB_PORT";
    public const string DbName = "DB_NAME";
    public const string DbUser = "DB_USER";
    public const string DbPassword = "DB_PASSWORD";

    public const string RabbitMqHost = "RABBITMQ_HOST";
    public const string RabbitMqPort = "RABBITMQ_PORT";
    public const string RabbitMqUser = "RABBITMQ_USER";
    public const string RabbitMqPassword = "RABBITMQ_PASSWORD";
    public const string RabbitMqEmailQueue = "RABBITMQ_EMAIL_QUEUE";

    public const string JwtKey = "JWT_KEY";
    public const string JwtIssuer = "JWT_ISSUER";
    public const string JwtAudience = "JWT_AUDIENCE";
    public const string JwtExpiresMinutes = "JWT_EXPIRES_MINUTES";
    public const string CorsAllowedOrigins = "CORS_ALLOWED_ORIGINS";
    public const string RestaurantTimeZone = "RESTAURANT_TIME_ZONE";

    public const string PayPalBaseUrl = "PAYPAL_BASE_URL";
    public const string PayPalClientId = "PAYPAL_CLIENT_ID";
    public const string PayPalClientSecret = "PAYPAL_CLIENT_SECRET";
    public const string PayPalReturnUrl = "PAYPAL_RETURN_URL";
    public const string PayPalCancelUrl = "PAYPAL_CANCEL_URL";

    public const string SmtpHost = "SMTP_HOST";
    public const string SmtpPort = "SMTP_PORT";
    public const string SmtpUsername = "SMTP_USERNAME";
    public const string SmtpPassword = "SMTP_PASSWORD";
    public const string SmtpUseSsl = "SMTP_USE_SSL";
    public const string SmtpFromEmail = "SMTP_FROM_EMAIL";
    public const string SmtpFromName = "SMTP_FROM_NAME";
}
