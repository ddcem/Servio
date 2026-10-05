namespace Servio.Services.Configuration;

public class RestaurantOptions
{
    /// <summary>IANA time zone of the restaurant, e.g. Europe/Sarajevo. Used for "today" and for times in emails.</summary>
    public string TimeZoneId { get; set; } = string.Empty;
}
