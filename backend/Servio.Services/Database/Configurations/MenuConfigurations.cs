using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database.Configurations;

public class PreparationStationConfiguration : IEntityTypeConfiguration<PreparationStation>
{
    public void Configure(EntityTypeBuilder<PreparationStation> builder)
    {
        builder.Property(x => x.Name).IsRequired().HasMaxLength(30);
        builder.HasIndex(x => x.Name).IsUnique();
    }
}

public class MenuCategoryConfiguration : IEntityTypeConfiguration<MenuCategory>
{
    public void Configure(EntityTypeBuilder<MenuCategory> builder)
    {
        builder.Property(x => x.Name).IsRequired().HasMaxLength(50);
        builder.HasIndex(x => x.Name).IsUnique();

        builder.HasOne(x => x.PreparationStation)
            .WithMany(x => x.Categories)
            .HasForeignKey(x => x.PreparationStationId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

public class ItemTagConfiguration : IEntityTypeConfiguration<ItemTag>
{
    public void Configure(EntityTypeBuilder<ItemTag> builder)
    {
        builder.Property(x => x.Name).IsRequired().HasMaxLength(30);
        builder.HasIndex(x => x.Name).IsUnique();
    }
}

public class MenuItemConfiguration : IEntityTypeConfiguration<MenuItem>
{
    public void Configure(EntityTypeBuilder<MenuItem> builder)
    {
        builder.Property(x => x.Name).IsRequired().HasMaxLength(100);
        builder.Property(x => x.Description).HasMaxLength(500);
        builder.Property(x => x.Price).HasPrecision(10, 2);
        builder.Property(x => x.ImageContentType).HasMaxLength(50);

        builder.HasIndex(x => x.Name);

        builder.HasOne(x => x.Category)
            .WithMany(x => x.MenuItems)
            .HasForeignKey(x => x.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(x => x.Tags)
            .WithMany(x => x.MenuItems)
            .UsingEntity<Dictionary<string, object>>(
                "MenuItemTags",
                r => r.HasOne<ItemTag>().WithMany().HasForeignKey("ItemTagId").OnDelete(DeleteBehavior.Restrict),
                l => l.HasOne<MenuItem>().WithMany().HasForeignKey("MenuItemId").OnDelete(DeleteBehavior.Cascade));
    }
}
