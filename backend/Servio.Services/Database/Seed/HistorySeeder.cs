using Microsoft.EntityFrameworkCore;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Services.Common;
using Servio.Services.Database.Entities;
using Servio.Services.Orders;

namespace Servio.Services.Database.Seed;

/// <summary>
/// Generates about three months of realistic restaurant activity relative to the first start:
/// paid orders with kitchen/bar tickets, tips, a few cancellations and refunds, reservations,
/// recommender feedback and today's open tables. The order patterns (steak with red wine, burgers
/// with fries and beer, ćevapi with Bosnian coffee...) give analytics and the recommender real data.
/// A fixed random seed keeps the data the same on every fresh install.
/// </summary>
public class HistorySeeder(ServioDbContext context, IRestaurantClock clock)
{
    private const int HistoryDays = 90;
    private const int RecommenderLaunchedDaysAgo = 60;
    private const int InactiveWaiterLeftDaysAgo = 45;

    private readonly Random _random = new(2026);
    private readonly Dictionary<(DateTime Day, int StationId), int> _ticketCounters = [];
    private readonly Dictionary<DateTime, int> _orderCounters = [];
    private readonly Dictionary<int, List<(DateTime From, DateTime To)>> _tableBusy = [];

    private Dictionary<string, MenuItem> _menu = [];
    private Dictionary<string, User> _users = [];
    private List<RestaurantTable> _tables = [];
    private PreparationStation _kitchen = null!;
    private PreparationStation _bar = null!;
    private PaymentMethod _cash = null!;
    private RestaurantSettings _settings = null!;

    /// <summary>Main course → items guests often order with it, with the chance per guest.</summary>
    private static readonly Dictionary<string, (string Item, double Chance)[]> Pairings = new()
    {
        ["Ribeye Steak"] = [("Red Wine", 0.55), ("French Fries", 0.35), ("Grilled Vegetables", 0.3), ("Mashed Potatoes", 0.12)],
        ["Grilled Salmon"] = [("White Wine", 0.55), ("Grilled Vegetables", 0.45), ("Sparkling Water", 0.3)],
        ["Pasta Carbonara"] = [("White Wine", 0.35), ("Garlic Bread", 0.4), ("Coca Cola", 0.25)],
        ["Chicken Burger"] = [("Coca Cola", 0.45), ("French Fries", 0.6), ("Lemonade", 0.2)],
        ["Beef Burger"] = [("Draft Beer", 0.5), ("French Fries", 0.65), ("Coca Cola", 0.2)],
        ["Spicy Arrabbiata"] = [("Draft Beer", 0.3), ("Garlic Bread", 0.35), ("Lemonade", 0.25)],
        ["Mushroom Risotto"] = [("White Wine", 0.4), ("Caesar Salad", 0.25), ("Sparkling Water", 0.2)],
        ["Ćevapi"] = [("Draft Beer", 0.4), ("Coca Cola", 0.3)]
    };

    private static readonly Dictionary<string, string> FavouriteDessert = new()
    {
        ["Ribeye Steak"] = "Chocolate Lava Cake",
        ["Pasta Carbonara"] = "Tiramisu",
        ["Ćevapi"] = "Baklava",
        ["Grilled Salmon"] = "Cheesecake"
    };

    private static readonly (string Item, int Weight)[] Mains =
    [
        ("Ribeye Steak", 14), ("Grilled Salmon", 10), ("Pasta Carbonara", 14), ("Chicken Burger", 12),
        ("Beef Burger", 14), ("Spicy Arrabbiata", 7), ("Mushroom Risotto", 8), ("Ćevapi", 16)
    ];

    private static readonly (string Item, int Weight)[] Appetizers =
        [("Bruschetta", 8), ("Mozzarella Sticks", 6), ("Chicken Wings", 8), ("Caesar Salad", 7), ("Tomato Soup", 3)];

    private static readonly (string Item, int Weight)[] MealDrinks =
    [
        ("Coca Cola", 10), ("Sparkling Water", 7), ("Still Water", 3), ("Lemonade", 5), ("Orange Juice", 4),
        ("Draft Beer", 8), ("Red Wine", 5), ("White Wine", 4)
    ];

    private static readonly (string Item, int Weight)[] Desserts =
        [("Tiramisu", 6), ("Cheesecake", 6), ("Chocolate Lava Cake", 5), ("Baklava", 5)];

    private static readonly (string Item, int Weight)[] Coffees =
        [("Espresso", 6), ("Cappuccino", 5), ("Bosnian Coffee", 7), ("Tea", 2)];

    private static readonly (string Item, int Weight)[] BarOnly =
    [
        ("Espresso", 8), ("Cappuccino", 7), ("Bosnian Coffee", 6), ("Tea", 2), ("Draft Beer", 8), ("Mojito", 4),
        ("Aperol Spritz", 5), ("Coca Cola", 5), ("Lemonade", 3), ("Orange Juice", 3), ("Sparkling Water", 2)
    ];

    private static readonly string[] RefundReasons =
    [
        "Steak was overcooked", "Dish arrived cold", "Wrong drink was served", "Long waiting time", "Guest found the dish too salty"
    ];

    private static readonly string[] GuestNames =
    [
        "Amra Hadžić", "Emir Kovačević", "Lejla Mehić", "Adnan Delić", "Selma Hodžić", "Haris Begović", "Lana Jurić",
        "Mirza Softić", "Ivana Marić", "Kenan Alić", "Sara Novak", "Tarik Mujić", "Maja Petrović", "Dino Halilović",
        "Nina Babić", "Edin Šehić", "Ajla Karić", "James Miller", "Anna Schmidt", "Luca Rossi"
    ];

    public async Task SeedAsync(CancellationToken cancellationToken)
    {
        await LoadReferenceDataAsync(cancellationToken);

        var today = clock.ToLocal(clock.UtcNow).Date;
        for (var day = today.AddDays(-HistoryDays); day < today; day = day.AddDays(1))
        {
            SeedDay(day, clock.ToUtc(day.AddHours(23).AddMinutes(30)));
        }

        // Earlier today: paid orders that ended at least half an hour ago, then a few tables open right now.
        SeedDay(today, clock.UtcNow.AddMinutes(-30));
        SeedOpenTables();
        SeedReservations(today);

        await context.SaveChangesAsync(cancellationToken);
    }

    private async Task LoadReferenceDataAsync(CancellationToken cancellationToken)
    {
        _menu = await context.MenuItems.Include(x => x.Category).ToDictionaryAsync(x => x.Name, cancellationToken);
        _users = await context.Users.ToDictionaryAsync(x => x.Username, cancellationToken);
        _tables = await context.RestaurantTables.Include(x => x.Area).OrderBy(x => x.Number).ToListAsync(cancellationToken);
        _kitchen = await context.PreparationStations.FirstAsync(x => x.Name == PreparationStations.Kitchen, cancellationToken);
        _bar = await context.PreparationStations.FirstAsync(x => x.Name == PreparationStations.Bar, cancellationToken);
        _cash = await context.PaymentMethods.FirstAsync(x => x.Name == PaymentMethods.Cash, cancellationToken);
        _settings = await context.RestaurantSettings.FirstAsync(cancellationToken);
    }

    private void SeedDay(DateTime localDay, DateTime latestCloseUtc)
    {
        var orderCount = localDay.DayOfWeek switch
        {
            DayOfWeek.Friday or DayOfWeek.Saturday => _random.Next(30, 41),
            DayOfWeek.Sunday => _random.Next(22, 31),
            _ => _random.Next(16, 27)
        };

        var daysAgo = (clock.ToLocal(clock.UtcNow).Date - localDay).Days;
        var waiters = daysAgo > InactiveWaiterLeftDaysAgo
            ? new[] { "mobile", "waiter", "waiter2", "waiter3" }
            : new[] { "mobile", "waiter", "waiter2" };

        for (var i = 0; i < orderCount; i++)
        {
            var drinksOnly = _random.NextDouble() < 0.25;
            var openedLocal = localDay.Add(PickOpeningTime(drinksOnly));
            var openedUtc = clock.ToUtc(openedLocal);
            var duration = TimeSpan.FromMinutes(drinksOnly ? _random.Next(20, 61) : _random.Next(45, 101));

            if (openedUtc + duration > latestCloseUtc)
            {
                continue;
            }

            var guests = PickGuestCount();
            var table = FindFreeTable(guests, openedUtc, openedUtc + duration, preferBar: drinksOnly);
            if (table is null)
            {
                continue;
            }

            var waiter = _users[waiters[_random.Next(waiters.Length)]];
            var rounds = drinksOnly ? BuildDrinksRounds(guests) : BuildMealRounds(guests, duration);
            var cancelled = _random.NextDouble() < 0.02;

            var order = CreateOrder(table, waiter, guests, openedUtc, rounds, cancelled ? OrderStatus.Cancelled : OrderStatus.Completed, null);
            if (!cancelled)
            {
                // The bill is paid a few minutes after the last plate or drink was served.
                var paidAfterService = (order.Tickets.Max(x => x.ServedAt) ?? openedUtc).AddMinutes(_random.Next(5, 16));
                var paidUtc = paidAfterService > openedUtc + duration ? paidAfterService : openedUtc + duration;
                duration = paidUtc - openedUtc;
                AddPayment(order, waiter, paidUtc);
                if (daysAgo <= RecommenderLaunchedDaysAgo && !drinksOnly)
                {
                    AddRecommendationEvents(order, waiter, rounds[0]);
                }
            }

            MarkBusy(table, openedUtc, openedUtc + duration);
        }
    }

    /// <summary>Four tables are in use right now, with tickets at every stage for a live demo.</summary>
    private void SeedOpenTables()
    {
        var now = clock.UtcNow;
        (int Guests, int MinutesAgo, TicketStatus LastRound, bool DrinksOnly)[] open =
        [
            (3, 35, TicketStatus.Ready, false),
            (4, 18, TicketStatus.Preparing, false),
            (2, 6, TicketStatus.New, false),
            (2, 12, TicketStatus.Served, true)
        ];

        foreach (var (guests, minutesAgo, lastRound, drinksOnly) in open)
        {
            var openedUtc = now.AddMinutes(-minutesAgo);
            var table = FindFreeTable(guests, openedUtc, now.AddHours(2), preferBar: drinksOnly);
            if (table is null)
            {
                continue;
            }

            var rounds = drinksOnly ? BuildDrinksRounds(guests) : BuildMealRounds(guests, TimeSpan.Zero);
            CreateOrder(table, _users["mobile"], guests, openedUtc, rounds, OrderStatus.Open, lastRound);
            MarkBusy(table, openedUtc, now.AddHours(2));
        }
    }

    private Order CreateOrder(RestaurantTable table, User waiter, int guests, DateTime openedUtc,
        List<Round> rounds, OrderStatus status, TicketStatus? openLastRoundStatus)
    {
        var localDay = clock.ToLocal(openedUtc).Date;
        var order = new Order
        {
            OrderNumber = $"{localDay:yyyyMMdd}-{NextCounter(_orderCounters, localDay):0000}",
            Table = table,
            GuestCount = guests,
            Waiter = waiter,
            Status = status,
            TaxRate = _settings.TaxRate,
            CurrencyId = _settings.CurrencyId,
            OpenedAt = openedUtc
        };

        for (var r = 0; r < rounds.Count; r++)
        {
            var round = rounds[r];
            var createdUtc = openedUtc + round.Offset;
            var isLastRound = r == rounds.Count - 1;

            foreach (var stationGroup in round.Items.GroupBy(x => x.Key.Category.PreparationStationId))
            {
                var station = stationGroup.Key == _kitchen.Id ? _kitchen : _bar;
                var targetStatus = status switch
                {
                    OrderStatus.Cancelled => TicketStatus.Cancelled,
                    OrderStatus.Open when isLastRound => openLastRoundStatus ?? TicketStatus.New,
                    _ => TicketStatus.Served
                };

                var ticket = CreateTicket(order, station, localDay, createdUtc, targetStatus, waiter);
                foreach (var (menuItem, quantity) in stationGroup)
                {
                    order.Items.Add(new OrderItem
                    {
                        Order = order,
                        OrderTicket = ticket,
                        MenuItem = menuItem,
                        Quantity = quantity,
                        UnitPrice = menuItem.Price,
                        Note = menuItem.Name == "Ribeye Steak" && _random.NextDouble() < 0.4 ? "Medium rare" : null
                    });
                }
            }
        }

        if (status == OrderStatus.Cancelled)
        {
            order.ClosedAt = openedUtc.AddMinutes(4);
            order.CancelledByUser = waiter;
            order.CancellationReason = "Guests left before the order was prepared";
        }

        OrderCalculator.Recalculate(order);
        context.Orders.Add(order);
        return order;
    }

    private OrderTicket CreateTicket(Order order, PreparationStation station, DateTime localDay, DateTime createdUtc,
        TicketStatus targetStatus, User waiter)
    {
        var isKitchen = station.Id == _kitchen.Id;
        var stationUser = _users[isKitchen ? "kitchen" : "bar"];
        var prefix = isKitchen ? 'K' : 'B';

        var ticket = new OrderTicket
        {
            Order = order,
            Station = station,
            TicketNumber = $"{prefix}{NextCounter(_ticketCounters, (localDay, station.Id)):000}",
            Status = targetStatus,
            CreatedAt = createdUtc
        };
        order.Tickets.Add(ticket);
        AddTicketHistory(ticket, null, TicketStatus.New, waiter, createdUtc, null);

        if (targetStatus == TicketStatus.Cancelled)
        {
            AddTicketHistory(ticket, TicketStatus.New, TicketStatus.Cancelled, waiter, createdUtc.AddMinutes(3),
                "Guests left before the order was prepared");
            return ticket;
        }

        if (targetStatus == TicketStatus.New)
        {
            return ticket;
        }

        ticket.StartedAt = createdUtc.AddMinutes(isKitchen ? _random.Next(1, 6) : _random.NextDouble() * 2.5 + 0.5);
        ticket.StartedByUser = stationUser;
        AddTicketHistory(ticket, TicketStatus.New, TicketStatus.Preparing, stationUser, ticket.StartedAt.Value, null);
        if (targetStatus == TicketStatus.Preparing)
        {
            return ticket;
        }

        ticket.ReadyAt = ticket.StartedAt.Value.AddMinutes(isKitchen ? _random.Next(10, 26) : _random.Next(2, 7));
        if (targetStatus == TicketStatus.Ready && ticket.ReadyAt > clock.UtcNow.AddMinutes(-2))
        {
            // Today's demo tickets became ready just now, so the waiter sees a fresh notification.
            ticket.ReadyAt = clock.UtcNow.AddMinutes(-2);
        }

        ticket.ReadyByUser = stationUser;
        AddTicketHistory(ticket, TicketStatus.Preparing, TicketStatus.Ready, stationUser, ticket.ReadyAt.Value, null);
        if (targetStatus == TicketStatus.Ready)
        {
            context.Notifications.Add(new Notification
            {
                User = waiter,
                Type = NotificationType.TicketReady,
                Title = $"Table {order.Table.Number} – {(isKitchen ? "food" : "drinks")} ready",
                Body = $"Ticket {ticket.TicketNumber} is ready {(isKitchen ? "in the kitchen" : "at the bar")}.",
                OrderTicket = ticket,
                CreatedAt = ticket.ReadyAt.Value
            });
            return ticket;
        }

        ticket.ServedAt = ticket.ReadyAt.Value.AddMinutes(_random.Next(1, 5));
        AddTicketHistory(ticket, TicketStatus.Ready, TicketStatus.Served, waiter, ticket.ServedAt.Value, null);
        return ticket;
    }

    private static void AddTicketHistory(OrderTicket ticket, TicketStatus? from, TicketStatus to, User user, DateTime at, string? reason) =>
        ticket.StatusHistory.Add(new OrderTicketStatusHistory
        {
            FromStatus = from,
            ToStatus = to,
            ChangedByUser = user,
            ChangedAt = at,
            Reason = reason
        });

    private void AddPayment(Order order, User waiter, DateTime paidUtc)
    {
        int[] tips = [0, 0, 0, 0, 10, 10, 10, 15, 15, 20];
        var tipPercent = tips[_random.Next(tips.Length)];
        var tipAmount = Money.Percent(order.Subtotal, tipPercent);
        var amount = order.Total + tipAmount;
        var cashReceived = Math.Ceiling(amount / 5m) * 5m + (_random.NextDouble() < 0.3 ? 10m : 0m);

        order.ClosedAt = paidUtc;
        var payment = new Payment
        {
            Order = order,
            PaymentMethod = _cash,
            Status = PaymentStatus.Completed,
            TipPercent = tipPercent,
            TipAmount = tipAmount,
            Amount = amount,
            CashReceived = cashReceived,
            ChangeGiven = cashReceived - amount,
            CapturedAmount = amount,
            ProcessedByUser = waiter,
            CreatedAt = paidUtc,
            CompletedAt = paidUtc
        };
        order.Payments.Add(payment);

        if (_random.NextDouble() < 0.015)
        {
            var refundAmount = Money.Round(order.Items.Max(x => x.UnitPrice));
            payment.Refunds.Add(new Refund
            {
                Payment = payment,
                Amount = refundAmount,
                Reason = RefundReasons[_random.Next(RefundReasons.Length)],
                Status = RefundStatus.Completed,
                RefundedByUser = _users["admin"],
                CreatedAt = paidUtc.AddMinutes(_random.Next(5, 120))
            });
            payment.Status = refundAmount >= amount ? PaymentStatus.Refunded : PaymentStatus.PartiallyRefunded;
        }
    }

    /// <summary>
    /// Suggestions the waiter saw for each main course: the classic pairing drink and side.
    /// Accepted means the guest actually ordered it, exactly as the live system records it.
    /// </summary>
    private void AddRecommendationEvents(Order order, User waiter, Round firstRound)
    {
        var orderedNames = order.Items.Select(x => x.MenuItem.Name).ToHashSet();
        foreach (var main in firstRound.Items.Keys.Where(x => Pairings.ContainsKey(x.Name)))
        {
            foreach (var (item, chance) in Pairings[main.Name].Take(2))
            {
                context.RecommendationEvents.Add(new RecommendationEvent
                {
                    Order = order,
                    Waiter = waiter,
                    SourceMenuItem = main,
                    RecommendedMenuItem = _menu[item],
                    Score = Math.Round((decimal)(0.45 + chance * 0.6 + _random.NextDouble() * 0.05), 4),
                    Reason = $"Ordered with {main.Name} in {chance * 100:0}% of orders",
                    WasAccepted = orderedNames.Contains(item),
                    CreatedAt = order.OpenedAt.AddMinutes(1)
                });
            }
        }
    }

    private void SeedReservations(DateTime today)
    {
        var admin = _users["admin"];
        var tableIntervals = new Dictionary<int, List<(DateTime, DateTime)>>();

        for (var day = today.AddDays(-HistoryDays); day <= today.AddDays(14); day = day.AddDays(1))
        {
            var count = day < today ? _random.Next(2, 6) : _random.Next(1, 5);
            for (var i = 0; i < count; i++)
            {
                var partySize = _random.Next(2, 9);
                var startLocal = day.AddHours(_random.Next(18, 21)).AddMinutes(_random.Next(0, 2) * 30);
                var startUtc = clock.ToUtc(startLocal);
                var endUtc = startUtc.AddHours(2);
                if (startUtc < clock.UtcNow.AddHours(1) && day >= today)
                {
                    continue;
                }

                var table = _tables
                    .Where(x => x.Capacity >= partySize && x.Capacity <= partySize + 4)
                    .Where(x => !tableIntervals.GetValueOrDefault(x.Id, []).Any(b => b.Item1 < endUtc && b.Item2 > startUtc))
                    .OrderBy(_ => _random.Next())
                    .FirstOrDefault();
                if (table is null)
                {
                    continue;
                }

                if (!tableIntervals.TryGetValue(table.Id, out var intervals))
                {
                    tableIntervals[table.Id] = intervals = [];
                }
                intervals.Add((startUtc, endUtc));

                var finalStatus = day >= today
                    ? (_random.NextDouble() < 0.6 ? ReservationStatus.Confirmed : ReservationStatus.Pending)
                    : _random.NextDouble() switch
                    {
                        < 0.75 => ReservationStatus.Completed,
                        < 0.85 => ReservationStatus.NoShow,
                        _ => ReservationStatus.Cancelled
                    };

                AddReservation(table, partySize, startUtc, endUtc, finalStatus, admin);
            }
        }

        // One confirmed reservation starting soon, so a table shows as Reserved right away.
        var soonTable = _tables.First(x => x.Number == 7);
        var soonStart = clock.UtcNow.AddMinutes(45);
        if (!tableIntervals.GetValueOrDefault(soonTable.Id, []).Any(b => b.Item1 < soonStart.AddHours(2) && b.Item2 > soonStart)
            && !IsBusy(soonTable, soonStart, soonStart.AddHours(2)))
        {
            AddReservation(soonTable, 2, soonStart, soonStart.AddHours(2), ReservationStatus.Confirmed, admin);
        }
    }

    private void AddReservation(RestaurantTable table, int partySize, DateTime startUtc, DateTime endUtc,
        ReservationStatus finalStatus, User admin)
    {
        var name = GuestNames[_random.Next(GuestNames.Length)];
        var createdUtc = startUtc.AddDays(-_random.Next(1, 10)).AddHours(-_random.Next(0, 6));
        if (createdUtc > clock.UtcNow)
        {
            createdUtc = clock.UtcNow.AddMinutes(-_random.Next(10, 600));
        }

        var reservation = new Reservation
        {
            Table = table,
            GuestName = name,
            GuestPhone = $"+387 6{_random.Next(1, 4)} {_random.Next(100, 1000)} {_random.Next(100, 1000)}",
            GuestEmail = _random.NextDouble() < 0.6 ? $"{name.Split(' ')[0].ToLowerInvariant()}.guest@example.com" : null,
            PartySize = partySize,
            StartTime = startUtc,
            EndTime = endUtc,
            Status = finalStatus,
            Note = _random.NextDouble() < 0.2 ? "Birthday celebration" : null,
            CreatedByUser = admin,
            CreatedAt = createdUtc
        };

        void History(ReservationStatus? from, ReservationStatus to, DateTime at, string? reason = null) =>
            reservation.StatusHistory.Add(new ReservationStatusHistory
            {
                FromStatus = from, ToStatus = to, ChangedByUser = admin, ChangedAt = at, Reason = reason
            });

        History(null, ReservationStatus.Pending, createdUtc);
        if (finalStatus != ReservationStatus.Pending)
        {
            var confirmedAt = createdUtc.AddHours(_random.Next(1, 12));
            History(ReservationStatus.Pending, ReservationStatus.Confirmed, confirmedAt < clock.UtcNow ? confirmedAt : createdUtc);

            switch (finalStatus)
            {
                case ReservationStatus.Completed:
                    History(ReservationStatus.Confirmed, ReservationStatus.Completed, startUtc.AddMinutes(_random.Next(0, 15)));
                    break;
                case ReservationStatus.NoShow:
                    History(ReservationStatus.Confirmed, ReservationStatus.NoShow, startUtc.AddMinutes(30));
                    break;
                case ReservationStatus.Cancelled:
                    History(ReservationStatus.Confirmed, ReservationStatus.Cancelled, startUtc.AddHours(-_random.Next(3, 30)),
                        "Guest called to cancel");
                    break;
            }
        }

        context.Reservations.Add(reservation);
    }

    private sealed record Round(TimeSpan Offset, Dictionary<MenuItem, int> Items);

    private List<Round> BuildMealRounds(int guests, TimeSpan duration)
    {
        var first = new Dictionary<MenuItem, int>();
        var mains = new List<string>();

        for (var appetizers = 0; appetizers < (guests + 1) / 2; appetizers++)
        {
            if (_random.NextDouble() < 0.3)
            {
                var appetizer = Pick(Appetizers);
                Add(first, appetizer);
                if (appetizer == "Chicken Wings" && _random.NextDouble() < 0.4)
                {
                    Add(first, "Draft Beer");
                }
            }
        }

        for (var guest = 0; guest < guests; guest++)
        {
            if (_random.NextDouble() > 0.85)
            {
                Add(first, Pick(MealDrinks));
                continue;
            }

            var main = Pick(Mains);
            mains.Add(main);
            Add(first, main);

            var hadDrink = false;
            foreach (var (item, chance) in Pairings[main])
            {
                var isDrink = _menu[item].Category.PreparationStationId == _bar.Id;
                if ((isDrink && hadDrink) || _random.NextDouble() >= chance)
                {
                    continue;
                }

                Add(first, item);
                hadDrink |= isDrink;
            }

            if (!hadDrink && _random.NextDouble() < 0.6)
            {
                Add(first, Pick(MealDrinks));
            }
        }

        var rounds = new List<Round> { new(TimeSpan.Zero, first) };

        if (_random.NextDouble() < 0.4 && duration > TimeSpan.FromMinutes(55))
        {
            var second = new Dictionary<MenuItem, int>();
            foreach (var main in mains)
            {
                if (_random.NextDouble() < 0.35)
                {
                    Add(second, FavouriteDessert.TryGetValue(main, out var favourite) && _random.NextDouble() < 0.6
                        ? favourite
                        : Pick(Desserts));
                }

                if (_random.NextDouble() < 0.45)
                {
                    Add(second, main == "Ćevapi" && _random.NextDouble() < 0.6 ? "Bosnian Coffee" : Pick(Coffees));
                }
            }

            if (second.Count > 0)
            {
                rounds.Add(new Round(TimeSpan.FromMinutes(_random.Next(35, (int)duration.TotalMinutes - 15)), second));
            }
        }

        return rounds;
    }

    private List<Round> BuildDrinksRounds(int guests)
    {
        var items = new Dictionary<MenuItem, int>();
        for (var guest = 0; guest < guests; guest++)
        {
            Add(items, Pick(BarOnly));
            if (_random.NextDouble() < 0.2)
            {
                Add(items, Pick(BarOnly));
            }
        }

        return [new Round(TimeSpan.Zero, items)];
    }

    private void Add(Dictionary<MenuItem, int> items, string name)
    {
        var item = _menu[name];
        items[item] = items.GetValueOrDefault(item) + 1;
    }

    private string Pick((string Item, int Weight)[] options)
    {
        var roll = _random.Next(options.Sum(x => x.Weight));
        foreach (var (item, weight) in options)
        {
            if (roll < weight)
            {
                return item;
            }

            roll -= weight;
        }

        return options[^1].Item;
    }

    private TimeSpan PickOpeningTime(bool drinksOnly)
    {
        var roll = _random.NextDouble();
        var minutes = drinksOnly
            ? _random.Next(9 * 60, 22 * 60)
            : roll < 0.4 ? _random.Next(12 * 60, 15 * 60)
            : roll < 0.9 ? _random.Next(18 * 60, 21 * 60 + 30)
            : _random.Next(11 * 60, 22 * 60);
        return TimeSpan.FromMinutes(minutes);
    }

    private int PickGuestCount() => _random.NextDouble() switch
    {
        < 0.15 => 1,
        < 0.55 => 2,
        < 0.70 => 3,
        < 0.88 => 4,
        < 0.95 => _random.Next(5, 7),
        _ => _random.Next(7, 11)
    };

    private RestaurantTable? FindFreeTable(int guests, DateTime fromUtc, DateTime toUtc, bool preferBar) =>
        _tables
            .Where(x => x.Capacity >= guests && !IsBusy(x, fromUtc, toUtc))
            .OrderBy(x => preferBar && x.Area.Name == "Bar Area" ? 0 : 1)
            .ThenBy(x => x.Capacity)
            .ThenBy(_ => _random.Next())
            .FirstOrDefault();

    private bool IsBusy(RestaurantTable table, DateTime fromUtc, DateTime toUtc) =>
        _tableBusy.TryGetValue(table.Id, out var busy) && busy.Any(b => b.From < toUtc && b.To > fromUtc);

    private void MarkBusy(RestaurantTable table, DateTime fromUtc, DateTime toUtc)
    {
        if (!_tableBusy.TryGetValue(table.Id, out var busy))
        {
            _tableBusy[table.Id] = busy = [];
        }

        busy.Add((fromUtc, toUtc));
    }

    private static int NextCounter<TKey>(Dictionary<TKey, int> counters, TKey key) where TKey : notnull =>
        counters[key] = counters.GetValueOrDefault(key) + 1;
}
