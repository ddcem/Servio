namespace Servio.Services.Database.Entities;

public class RestaurantTable : IEntity
{
    public int Id { get; set; }
    public int Number { get; set; }
    public int Capacity { get; set; }
    public int AreaId { get; set; }
    public bool IsActive { get; set; } = true;
    /// <summary>The waiter serving this table in the current shift; null = any waiter.</summary>
    public int? AssignedWaiterId { get; set; }

    public TableArea Area { get; set; } = null!;
    public User? AssignedWaiter { get; set; }
    public ICollection<Reservation> Reservations { get; set; } = [];
    public ICollection<Order> Orders { get; set; } = [];
}
