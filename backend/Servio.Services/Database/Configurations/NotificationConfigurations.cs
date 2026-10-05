using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.Property(x => x.Title).IsRequired().HasMaxLength(100);
        builder.Property(x => x.Body).IsRequired().HasMaxLength(500);

        builder.HasIndex(x => new { x.UserId, x.IsRead });

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.OrderTicket)
            .WithMany()
            .HasForeignKey(x => x.OrderTicketId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Reservation)
            .WithMany()
            .HasForeignKey(x => x.ReservationId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class RecommendationEventConfiguration : IEntityTypeConfiguration<RecommendationEvent>
{
    public void Configure(EntityTypeBuilder<RecommendationEvent> builder)
    {
        builder.Property(x => x.Score).HasPrecision(6, 4);
        builder.Property(x => x.Reason).IsRequired().HasMaxLength(200);

        builder.HasIndex(x => new { x.SourceMenuItemId, x.RecommendedMenuItemId });

        builder.HasOne(x => x.Order)
            .WithMany()
            .HasForeignKey(x => x.OrderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Waiter)
            .WithMany()
            .HasForeignKey(x => x.WaiterId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.SourceMenuItem)
            .WithMany()
            .HasForeignKey(x => x.SourceMenuItemId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.RecommendedMenuItem)
            .WithMany()
            .HasForeignKey(x => x.RecommendedMenuItemId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
