using Microsoft.EntityFrameworkCore;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database;

public class ServioDbContext(DbContextOptions<ServioDbContext> options) : DbContext(options)
{
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<User> Users => Set<User>();
    public DbSet<UserSession> UserSessions => Set<UserSession>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<PreparationStation> PreparationStations => Set<PreparationStation>();
    public DbSet<MenuCategory> MenuCategories => Set<MenuCategory>();
    public DbSet<ItemTag> ItemTags => Set<ItemTag>();
    public DbSet<MenuItem> MenuItems => Set<MenuItem>();
    public DbSet<TableArea> TableAreas => Set<TableArea>();
    public DbSet<RestaurantTable> RestaurantTables => Set<RestaurantTable>();
    public DbSet<Reservation> Reservations => Set<Reservation>();
    public DbSet<ReservationStatusHistory> ReservationStatusHistory => Set<ReservationStatusHistory>();
    public DbSet<Currency> Currencies => Set<Currency>();
    public DbSet<PaymentMethod> PaymentMethods => Set<PaymentMethod>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderTicket> OrderTickets => Set<OrderTicket>();
    public DbSet<OrderTicketStatusHistory> OrderTicketStatusHistory => Set<OrderTicketStatusHistory>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();
    public DbSet<Payment> Payments => Set<Payment>();
    public DbSet<Refund> Refunds => Set<Refund>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<RecommendationEvent> RecommendationEvents => Set<RecommendationEvent>();
    public DbSet<RestaurantSettings> RestaurantSettings => Set<RestaurantSettings>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ServioDbContext).Assembly);
    }
}
