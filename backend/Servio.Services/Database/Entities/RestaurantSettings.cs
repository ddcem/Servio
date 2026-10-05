namespace Servio.Services.Database.Entities;

public class RestaurantSettings
{
    public int Id { get; set; }
    public string RestaurantName { get; set; } = string.Empty;
    public int CurrencyId { get; set; }
    public decimal TaxRate { get; set; }
    public int? UpdatedByUserId { get; set; }
    public DateTime UpdatedAt { get; set; }

    public Currency Currency { get; set; } = null!;
    public User? UpdatedByUser { get; set; }
}
