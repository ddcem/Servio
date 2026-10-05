using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Servio.Model.Enums;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database.Configurations;

public class CurrencyConfiguration : IEntityTypeConfiguration<Currency>
{
    public void Configure(EntityTypeBuilder<Currency> builder)
    {
        builder.Property(x => x.Code).IsRequired().HasMaxLength(3);
        builder.Property(x => x.Name).IsRequired().HasMaxLength(50);
        builder.Property(x => x.Symbol).IsRequired().HasMaxLength(5);
        builder.HasIndex(x => x.Code).IsUnique();
    }
}

public class PaymentMethodConfiguration : IEntityTypeConfiguration<PaymentMethod>
{
    public void Configure(EntityTypeBuilder<PaymentMethod> builder)
    {
        builder.Property(x => x.Name).IsRequired().HasMaxLength(30);
        builder.HasIndex(x => x.Name).IsUnique();
    }
}

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.Property(x => x.TipPercent).HasPrecision(5, 2);
        builder.Property(x => x.TipAmount).HasPrecision(10, 2);
        builder.Property(x => x.Amount).HasPrecision(10, 2);
        builder.Property(x => x.CashReceived).HasPrecision(10, 2);
        builder.Property(x => x.ChangeGiven).HasPrecision(10, 2);
        builder.Property(x => x.CapturedAmount).HasPrecision(10, 2);
        builder.Property(x => x.PayPalOrderId).HasMaxLength(50);
        builder.Property(x => x.PayPalCaptureId).HasMaxLength(50);

        builder.HasIndex(x => x.PayPalOrderId).IsUnique();

        // Prevents paying the same order twice: at most one pending or completed payment per order.
        builder.HasIndex(x => x.OrderId)
            .IsUnique()
            .HasFilter($"\"Status\" IN ({(int)PaymentStatus.Pending}, {(int)PaymentStatus.Completed})")
            .HasDatabaseName("IX_Payments_OrderId_Active");

        builder.HasOne(x => x.Order)
            .WithMany(x => x.Payments)
            .HasForeignKey(x => x.OrderId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.PaymentMethod)
            .WithMany()
            .HasForeignKey(x => x.PaymentMethodId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ProcessedByUser)
            .WithMany()
            .HasForeignKey(x => x.ProcessedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class RefundConfiguration : IEntityTypeConfiguration<Refund>
{
    public void Configure(EntityTypeBuilder<Refund> builder)
    {
        builder.Property(x => x.Amount).HasPrecision(10, 2);
        builder.Property(x => x.Reason).IsRequired().HasMaxLength(500);
        builder.Property(x => x.PayPalRefundId).HasMaxLength(50);

        builder.HasOne(x => x.Payment)
            .WithMany(x => x.Refunds)
            .HasForeignKey(x => x.PaymentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.RefundedByUser)
            .WithMany()
            .HasForeignKey(x => x.RefundedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class RestaurantSettingsConfiguration : IEntityTypeConfiguration<RestaurantSettings>
{
    public void Configure(EntityTypeBuilder<RestaurantSettings> builder)
    {
        builder.Property(x => x.RestaurantName).IsRequired().HasMaxLength(100);
        builder.Property(x => x.TaxRate).HasPrecision(5, 2);

        builder.HasOne(x => x.Currency)
            .WithMany()
            .HasForeignKey(x => x.CurrencyId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.UpdatedByUser)
            .WithMany()
            .HasForeignKey(x => x.UpdatedByUserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
