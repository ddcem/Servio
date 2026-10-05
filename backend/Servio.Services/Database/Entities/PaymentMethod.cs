namespace Servio.Services.Database.Entities;

public class PaymentMethod : INamedEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
}
