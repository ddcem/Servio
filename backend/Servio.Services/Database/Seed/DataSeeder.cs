using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Services.Common;
using Servio.Services.Database.Entities;

namespace Servio.Services.Database.Seed;

/// <summary>
/// Seeds all data needed to run and test the application. Runs once, on an empty database.
/// Passwords are hashed with the same IPasswordHasher used at runtime.
/// </summary>
public class DataSeeder(
    ServioDbContext context,
    IPasswordHasher<User> passwordHasher,
    IRestaurantClock clock,
    ILogger<DataSeeder> logger)
{
    private const string TestPassword = "test";

    public async Task SeedAsync(CancellationToken cancellationToken = default)
    {
        if (await context.Roles.AnyAsync(cancellationToken))
        {
            return;
        }

        logger.LogInformation("Seeding database");

        await using var transaction = await context.Database.BeginTransactionAsync(cancellationToken);

        var roles = SeedRoles();
        var stations = SeedPreparationStations();
        var categories = SeedMenuCategories(stations);
        var tags = SeedItemTags();
        var areas = SeedTableAreas();
        var currencies = SeedCurrencies();
        SeedPaymentMethods();
        SeedTables(areas);
        SeedMenuItems(categories, tags);
        SeedUsers(roles);
        await context.SaveChangesAsync(cancellationToken);

        context.RestaurantSettings.Add(new RestaurantSettings
        {
            RestaurantName = "Servio Restaurant",
            CurrencyId = currencies["EUR"].Id,
            TaxRate = 17m,
            UpdatedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync(cancellationToken);

        await new HistorySeeder(context, clock).SeedAsync(cancellationToken);
        await SeedTableAssignmentsAsync(cancellationToken);

        await transaction.CommitAsync(cancellationToken);
        logger.LogInformation("Database seeded");
    }

    /// <summary>
    /// Today's shift: each active waiter has a section. Open demo orders belong to the waiter of their table,
    /// as they would after the admin assigned the tables.
    /// </summary>
    private async Task SeedTableAssignmentsAsync(CancellationToken cancellationToken)
    {
        var sections = new Dictionary<string, int[]>
        {
            ["mobile"] = [1, 2, 3, 4, 5, 6],
            ["waiter"] = [7, 8, 13, 14, 15, 16],
            ["waiter2"] = [9, 10, 11, 12]
        };

        var waiters = await context.Users
            .Where(x => sections.Keys.Contains(x.Username))
            .ToDictionaryAsync(x => x.Username, x => x.Id, cancellationToken);
        var tables = await context.RestaurantTables.ToListAsync(cancellationToken);
        foreach (var (username, numbers) in sections)
        {
            foreach (var table in tables.Where(t => numbers.Contains(t.Number)))
            {
                table.AssignedWaiterId = waiters[username];
            }
        }

        var openOrders = await context.Orders.Where(x => x.Status == OrderStatus.Open).ToListAsync(cancellationToken);
        foreach (var order in openOrders)
        {
            order.WaiterId = tables.First(t => t.Id == order.TableId).AssignedWaiterId ?? order.WaiterId;

            // "Order ready" notifications of these orders go to the waiter who now serves the table.
            await context.Notifications
                .Where(x => x.OrderTicket != null && x.OrderTicket.OrderId == order.Id)
                .ForEachAsync(x => x.UserId = order.WaiterId, cancellationToken);
        }

        await context.SaveChangesAsync(cancellationToken);
    }

    private Dictionary<string, Role> SeedRoles()
    {
        var roles = new[] { Roles.Admin, Roles.Waiter, Roles.Kitchen, Roles.Bar }
            .ToDictionary(name => name, name => new Role { Name = name });
        context.Roles.AddRange(roles.Values);
        return roles;
    }

    private Dictionary<string, PreparationStation> SeedPreparationStations()
    {
        var stations = new[] { PreparationStations.Kitchen, PreparationStations.Bar }
            .ToDictionary(name => name, name => new PreparationStation { Name = name });
        context.PreparationStations.AddRange(stations.Values);
        return stations;
    }

    private Dictionary<string, MenuCategory> SeedMenuCategories(Dictionary<string, PreparationStation> stations)
    {
        var kitchen = stations[PreparationStations.Kitchen];
        var bar = stations[PreparationStations.Bar];

        var categories = new[]
        {
            new MenuCategory { Name = "Appetizers", CourseType = CourseType.Appetizer, PreparationStation = kitchen, SortOrder = 1 },
            new MenuCategory { Name = "Main Course", CourseType = CourseType.MainCourse, PreparationStation = kitchen, SortOrder = 2 },
            new MenuCategory { Name = "Sides", CourseType = CourseType.Side, PreparationStation = kitchen, SortOrder = 3 },
            new MenuCategory { Name = "Desserts", CourseType = CourseType.Dessert, PreparationStation = kitchen, SortOrder = 4 },
            new MenuCategory { Name = "Soft Drinks", CourseType = CourseType.Drink, PreparationStation = bar, SortOrder = 5 },
            new MenuCategory { Name = "Hot Drinks", CourseType = CourseType.Drink, PreparationStation = bar, SortOrder = 6 },
            new MenuCategory { Name = "Alcoholic Drinks", CourseType = CourseType.Drink, PreparationStation = bar, SortOrder = 7 }
        }.ToDictionary(x => x.Name);

        context.MenuCategories.AddRange(categories.Values);
        return categories;
    }

    private Dictionary<string, ItemTag> SeedItemTags()
    {
        var tags = new[] { "Spicy", "Vegetarian", "Alcoholic", "Hot", "Cold", "Gluten-free", "Meat", "Fish", "Sweet", "Caffeinated" }
            .ToDictionary(name => name, name => new ItemTag { Name = name });
        context.ItemTags.AddRange(tags.Values);
        return tags;
    }

    private Dictionary<string, TableArea> SeedTableAreas()
    {
        var areas = new[] { "Main Hall", "Terrace", "Bar Area" }
            .ToDictionary(name => name, name => new TableArea { Name = name });
        context.TableAreas.AddRange(areas.Values);
        return areas;
    }

    private Dictionary<string, Currency> SeedCurrencies()
    {
        var currencies = new[]
        {
            new Currency { Code = "EUR", Name = "Euro", Symbol = "€" },
            new Currency { Code = "USD", Name = "US Dollar", Symbol = "$" }
        }.ToDictionary(x => x.Code);

        context.Currencies.AddRange(currencies.Values);
        return currencies;
    }

    private void SeedPaymentMethods()
    {
        context.PaymentMethods.AddRange(
            new PaymentMethod { Name = PaymentMethods.Cash },
            new PaymentMethod { Name = PaymentMethods.PayPal });
    }

    private void SeedTables(Dictionary<string, TableArea> areas)
    {
        (int Number, int Capacity, string Area)[] tables =
        [
            (1, 2, "Main Hall"), (2, 4, "Main Hall"), (3, 2, "Main Hall"), (4, 6, "Main Hall"),
            (5, 4, "Main Hall"), (6, 4, "Main Hall"), (7, 2, "Main Hall"), (8, 8, "Main Hall"),
            (9, 4, "Terrace"), (10, 4, "Terrace"), (11, 6, "Terrace"), (12, 2, "Terrace"),
            (13, 2, "Bar Area"), (14, 2, "Bar Area"), (15, 4, "Bar Area"), (16, 10, "Main Hall")
        ];

        context.RestaurantTables.AddRange(tables.Select(t => new RestaurantTable
        {
            Number = t.Number,
            Capacity = t.Capacity,
            Area = areas[t.Area]
        }));
    }

    private void SeedMenuItems(Dictionary<string, MenuCategory> categories, Dictionary<string, ItemTag> tags)
    {
        (string Name, string Description, decimal Price, string Category, string[] Tags)[] items =
        [
            ("Bruschetta", "Toasted bread with tomatoes, garlic and basil", 6.50m, "Appetizers", ["Vegetarian"]),
            ("Mozzarella Sticks", "Fried mozzarella with marinara dip", 7.00m, "Appetizers", ["Vegetarian"]),
            ("Chicken Wings", "Spicy buffalo wings with blue cheese dip", 9.50m, "Appetizers", ["Spicy", "Meat"]),
            ("Caesar Salad", "Romaine, parmesan, croutons and Caesar dressing", 8.00m, "Appetizers", ["Cold"]),
            ("Tomato Soup", "Creamy roasted tomato soup", 5.50m, "Appetizers", ["Vegetarian", "Hot", "Gluten-free"]),
            ("Ribeye Steak", "300 g grilled ribeye with herb butter", 28.00m, "Main Course", ["Meat", "Gluten-free"]),
            ("Grilled Salmon", "Salmon fillet with lemon butter sauce", 22.00m, "Main Course", ["Fish", "Gluten-free"]),
            ("Pasta Carbonara", "Spaghetti with pancetta, egg and parmesan", 13.50m, "Main Course", ["Meat"]),
            ("Chicken Burger", "Crispy chicken, cheddar, lettuce and house sauce", 12.00m, "Main Course", ["Meat"]),
            ("Beef Burger", "Beef patty, cheddar, bacon and pickles", 14.00m, "Main Course", ["Meat"]),
            ("Spicy Arrabbiata", "Penne in a spicy tomato sauce", 11.00m, "Main Course", ["Spicy", "Vegetarian"]),
            ("Mushroom Risotto", "Arborio rice with porcini mushrooms", 13.00m, "Main Course", ["Vegetarian", "Gluten-free"]),
            ("Ćevapi", "Ten grilled ćevapi in somun with onions", 10.00m, "Main Course", ["Meat"]),
            ("French Fries", "Crispy fries with sea salt", 3.50m, "Sides", ["Vegetarian", "Gluten-free"]),
            ("Grilled Vegetables", "Seasonal vegetables from the grill", 4.50m, "Sides", ["Vegetarian", "Gluten-free"]),
            ("Mashed Potatoes", "Creamy butter mashed potatoes", 3.50m, "Sides", ["Vegetarian", "Gluten-free"]),
            ("Garlic Bread", "Baguette with garlic butter", 3.00m, "Sides", ["Vegetarian"]),
            ("Tiramisu", "Classic Italian coffee dessert", 6.00m, "Desserts", ["Sweet", "Caffeinated"]),
            ("Cheesecake", "New York cheesecake with berry sauce", 6.50m, "Desserts", ["Sweet"]),
            ("Chocolate Lava Cake", "Warm chocolate cake with a molten centre", 7.00m, "Desserts", ["Sweet", "Hot"]),
            ("Baklava", "Walnut baklava with syrup", 4.50m, "Desserts", ["Sweet"]),
            ("Coca Cola", "0.33 l", 3.00m, "Soft Drinks", ["Cold", "Caffeinated"]),
            ("Sparkling Water", "0.5 l", 2.50m, "Soft Drinks", ["Cold"]),
            ("Still Water", "0.5 l", 2.00m, "Soft Drinks", ["Cold"]),
            ("Orange Juice", "Freshly squeezed, 0.25 l", 4.00m, "Soft Drinks", ["Cold"]),
            ("Lemonade", "Homemade lemonade with mint", 3.50m, "Soft Drinks", ["Cold"]),
            ("Espresso", "Single shot", 1.80m, "Hot Drinks", ["Hot", "Caffeinated"]),
            ("Cappuccino", "Espresso with steamed milk foam", 2.80m, "Hot Drinks", ["Hot", "Caffeinated"]),
            ("Bosnian Coffee", "Traditional coffee served in a džezva", 2.50m, "Hot Drinks", ["Hot", "Caffeinated"]),
            ("Tea", "Selection of herbal and black teas", 2.20m, "Hot Drinks", ["Hot"]),
            ("Red Wine", "House red, 0.2 l", 6.00m, "Alcoholic Drinks", ["Alcoholic"]),
            ("White Wine", "House white, 0.2 l", 6.00m, "Alcoholic Drinks", ["Alcoholic", "Cold"]),
            ("Draft Beer", "Local lager, 0.5 l", 4.00m, "Alcoholic Drinks", ["Alcoholic", "Cold"]),
            ("Mojito", "Rum, lime, mint and soda", 8.00m, "Alcoholic Drinks", ["Alcoholic", "Cold"]),
            ("Aperol Spritz", "Aperol, prosecco and soda", 8.00m, "Alcoholic Drinks", ["Alcoholic", "Cold"])
        ];

        var now = DateTime.UtcNow;
        context.MenuItems.AddRange(items.Select(i => new MenuItem
        {
            Name = i.Name,
            Description = i.Description,
            Price = i.Price,
            Category = categories[i.Category],
            Tags = i.Tags.Select(t => tags[t]).ToList(),
            Image = SeedImages.ForMenuItem(i.Name),
            ImageContentType = SeedImages.ContentType,
            CreatedAt = now
        }));
    }

    private void SeedUsers(Dictionary<string, Role> roles)
    {
        (string Username, string FirstName, string LastName, string Role, bool IsActive)[] users =
        [
            ("desktop", "Desktop", "Admin", Roles.Admin, true),
            ("admin", "Amar", "Hodžić", Roles.Admin, true),
            ("mobile", "John", "Smith", Roles.Waiter, true),
            ("waiter", "Mike", "Williams", Roles.Waiter, true),
            ("waiter2", "Lejla", "Begić", Roles.Waiter, true),
            ("waiter3", "Tom", "Brown", Roles.Waiter, false),
            ("kitchen", "Sarah", "Johnson", Roles.Kitchen, true),
            ("bar", "Emily", "Davis", Roles.Bar, true)
        ];

        var now = DateTime.UtcNow;
        foreach (var u in users)
        {
            var user = new User
            {
                Username = u.Username,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Email = $"{u.Username}@servio.app",
                PhoneNumber = "+387 61 000 000",
                Role = roles[u.Role],
                IsActive = u.IsActive,
                CreatedAt = now
            };
            user.PasswordHash = passwordHasher.HashPassword(user, TestPassword);
            context.Users.Add(user);
        }
    }
}
