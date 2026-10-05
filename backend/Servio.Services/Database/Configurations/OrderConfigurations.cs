using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Servio.Model.Enums;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database.Configurations;

public class OrderConfiguration : IEntityTypeConfiguration<Order>
{
    public void Configure(EntityTypeBuilder<Order> builder)
    {
        builder.Property(x => x.OrderNumber).IsRequired().HasMaxLength(20);
        builder.Property(x => x.Subtotal).HasPrecision(10, 2);
        builder.Property(x => x.TaxRate).HasPrecision(5, 2);
        builder.Property(x => x.TaxAmount).HasPrecision(10, 2);
        builder.Property(x => x.Total).HasPrecision(10, 2);
        builder.Property(x => x.CancellationReason).HasMaxLength(500);

        builder.HasIndex(x => x.OrderNumber).IsUnique();

        // A table can only have one open order at a time.
        builder.HasIndex(x => x.TableId)
            .IsUnique()
            .HasFilter($"\"Status\" = {(int)OrderStatus.Open}")
            .HasDatabaseName("IX_Orders_TableId_Open");

        builder.HasOne(x => x.Table)
            .WithMany(x => x.Orders)
            .HasForeignKey(x => x.TableId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Waiter)
            .WithMany()
            .HasForeignKey(x => x.WaiterId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Currency)
            .WithMany()
            .HasForeignKey(x => x.CurrencyId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.CancelledByUser)
            .WithMany()
            .HasForeignKey(x => x.CancelledByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class OrderTicketConfiguration : IEntityTypeConfiguration<OrderTicket>
{
    public void Configure(EntityTypeBuilder<OrderTicket> builder)
    {
        builder.Property(x => x.TicketNumber).IsRequired().HasMaxLength(10);

        builder.HasIndex(x => new { x.StationId, x.Status });

        builder.HasOne(x => x.Order)
            .WithMany(x => x.Tickets)
            .HasForeignKey(x => x.OrderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Station)
            .WithMany()
            .HasForeignKey(x => x.StationId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.StartedByUser)
            .WithMany()
            .HasForeignKey(x => x.StartedByUserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ReadyByUser)
            .WithMany()
            .HasForeignKey(x => x.ReadyByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class OrderTicketStatusHistoryConfiguration : IEntityTypeConfiguration<OrderTicketStatusHistory>
{
    public void Configure(EntityTypeBuilder<OrderTicketStatusHistory> builder)
    {
        builder.Property(x => x.Reason).HasMaxLength(500);

        builder.HasOne(x => x.OrderTicket)
            .WithMany(x => x.StatusHistory)
            .HasForeignKey(x => x.OrderTicketId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUser)
            .WithMany()
            .HasForeignKey(x => x.ChangedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class OrderItemConfiguration : IEntityTypeConfiguration<OrderItem>
{
    public void Configure(EntityTypeBuilder<OrderItem> builder)
    {
        builder.Property(x => x.UnitPrice).HasPrecision(10, 2);
        builder.Property(x => x.Note).HasMaxLength(200);

        builder.HasOne(x => x.Order)
            .WithMany(x => x.Items)
            .HasForeignKey(x => x.OrderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.OrderTicket)
            .WithMany(x => x.Items)
            .HasForeignKey(x => x.OrderTicketId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.MenuItem)
            .WithMany()
            .HasForeignKey(x => x.MenuItemId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
