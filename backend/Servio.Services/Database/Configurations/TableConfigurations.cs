using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database.Configurations;

public class TableAreaConfiguration : IEntityTypeConfiguration<TableArea>
{
    public void Configure(EntityTypeBuilder<TableArea> builder)
    {
        builder.Property(x => x.Name).IsRequired().HasMaxLength(50);
        builder.HasIndex(x => x.Name).IsUnique();
    }
}

public class RestaurantTableConfiguration : IEntityTypeConfiguration<RestaurantTable>
{
    public void Configure(EntityTypeBuilder<RestaurantTable> builder)
    {
        builder.HasIndex(x => x.Number).IsUnique();

        builder.HasOne(x => x.Area)
            .WithMany(x => x.Tables)
            .HasForeignKey(x => x.AreaId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ReservationConfiguration : IEntityTypeConfiguration<Reservation>
{
    public void Configure(EntityTypeBuilder<Reservation> builder)
    {
        builder.Property(x => x.GuestName).IsRequired().HasMaxLength(100);
        builder.Property(x => x.GuestPhone).IsRequired().HasMaxLength(20);
        builder.Property(x => x.GuestEmail).HasMaxLength(100);
        builder.Property(x => x.Note).HasMaxLength(500);

        builder.HasIndex(x => new { x.TableId, x.StartTime });

        builder.HasOne(x => x.Table)
            .WithMany(x => x.Reservations)
            .HasForeignKey(x => x.TableId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.CreatedByUser)
            .WithMany()
            .HasForeignKey(x => x.CreatedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ReservationStatusHistoryConfiguration : IEntityTypeConfiguration<ReservationStatusHistory>
{
    public void Configure(EntityTypeBuilder<ReservationStatusHistory> builder)
    {
        builder.Property(x => x.Reason).HasMaxLength(500);

        builder.HasOne(x => x.Reservation)
            .WithMany(x => x.StatusHistory)
            .HasForeignKey(x => x.ReservationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUser)
            .WithMany()
            .HasForeignKey(x => x.ChangedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
