using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using QuestPDF.Fluent;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Common;
using Servio.Services.Configuration;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Reports.Pdf;
using Servio.Services.Settings;

namespace Servio.Services.Reports;

/// <summary>
/// Sales and staff analytics. Every figure is aggregated in the database with one GROUP BY query;
/// days are counted in the restaurant's local time zone.
/// </summary>
public class ReportService(
    ServioDbContext context,
    ISettingsService settingsService,
    IRestaurantClock clock,
    IOptions<RestaurantOptions> restaurantOptions) : IReportService
{
    private const int DefaultPeriodDays = 30;
    private const int TopItemCount = 10;
    private const int LeastSoldItemCount = 5;

    private static readonly PaymentStatus[] PaidStatuses =
        [PaymentStatus.Completed, PaymentStatus.PartiallyRefunded, PaymentStatus.Refunded];

    private readonly string _timeZoneId = restaurantOptions.Value.TimeZoneId;

    public async Task<SalesReportResponse> GetSalesReportAsync(ReportPeriodSearchObject period,
        CancellationToken cancellationToken = default)
    {
        var (from, to, fromUtc, toUtc) = Resolve(period);
        var settings = await settingsService.GetAsync(cancellationToken);
        var paidOrders = PaidOrders(fromUtc, toUtc);

        var totals = await paidOrders
            .GroupBy(_ => 1)
            .Select(g => new
            {
                Revenue = g.Sum(x => x.Total),
                Tax = g.Sum(x => x.TaxAmount),
                Orders = g.Count(),
                Guests = g.Sum(x => x.GuestCount)
            })
            .FirstOrDefaultAsync(cancellationToken);

        var cancelledOrders = await context.Orders
            .CountAsync(x => x.Status == OrderStatus.Cancelled && x.ClosedAt >= fromUtc && x.ClosedAt < toUtc, cancellationToken);

        var refunds = await context.Refunds
            .Where(x => x.Status == RefundStatus.Completed && x.CreatedAt >= fromUtc && x.CreatedAt < toUtc)
            .SumAsync(x => x.Amount, cancellationToken);

        var paymentMethods = await context.Payments
            .Where(x => PaidStatuses.Contains(x.Status) && x.CompletedAt >= fromUtc && x.CompletedAt < toUtc)
            .GroupBy(x => x.PaymentMethod.Name)
            .Select(g => new { Method = g.Key, Count = g.Count(), Amount = g.Sum(x => x.Amount), Tips = g.Sum(x => x.TipAmount) })
            .ToListAsync(cancellationToken);

        var daily = await paidOrders
            .GroupBy(x => TimeZoneInfo.ConvertTimeBySystemTimeZoneId(x.ClosedAt!.Value, _timeZoneId).Date)
            .Select(g => new { Day = g.Key, Revenue = g.Sum(x => x.Total), Orders = g.Count() })
            .ToDictionaryAsync(x => DateOnly.FromDateTime(x.Day), cancellationToken);

        var soldItems = SoldItems(paidOrders);

        var topItems = await soldItems
            .GroupBy(x => new { x.MenuItemId, x.MenuItem.Name, Category = x.MenuItem.Category.Name, HasImage = x.MenuItem.Image != null })
            .Select(g => new ItemSalesResponse
            {
                MenuItemId = g.Key.MenuItemId,
                Name = g.Key.Name,
                CategoryName = g.Key.Category,
                HasImage = g.Key.HasImage,
                Quantity = g.Sum(x => x.Quantity),
                Revenue = g.Sum(x => x.UnitPrice * x.Quantity)
            })
            .OrderByDescending(x => x.Quantity)
            .ThenByDescending(x => x.Revenue)
            .Take(TopItemCount)
            .ToListAsync(cancellationToken);

        // Items still on the menu, including those that did not sell at all.
        var leastSold = await context.MenuItems
            .Where(x => !x.IsDeleted)
            .Select(m => new ItemSalesResponse
            {
                MenuItemId = m.Id,
                Name = m.Name,
                CategoryName = m.Category.Name,
                HasImage = m.Image != null,
                Quantity = soldItems.Where(x => x.MenuItemId == m.Id).Sum(x => (int?)x.Quantity) ?? 0,
                Revenue = soldItems.Where(x => x.MenuItemId == m.Id).Sum(x => (decimal?)(x.UnitPrice * x.Quantity)) ?? 0
            })
            .OrderBy(x => x.Quantity)
            .ThenBy(x => x.Name)
            .Take(LeastSoldItemCount)
            .ToListAsync(cancellationToken);

        var categories = await soldItems
            .GroupBy(x => x.MenuItem.Category.Name)
            .Select(g => new CategorySalesResponse
            {
                CategoryName = g.Key,
                Quantity = g.Sum(x => x.Quantity),
                Revenue = g.Sum(x => x.UnitPrice * x.Quantity)
            })
            .OrderByDescending(x => x.Revenue)
            .ToListAsync(cancellationToken);

        var revenue = totals?.Revenue ?? 0;
        var orderCount = totals?.Orders ?? 0;

        return new SalesReportResponse
        {
            From = from,
            To = to,
            CurrencySymbol = settings.CurrencySymbol,
            Revenue = revenue,
            TaxCollected = totals?.Tax ?? 0,
            Tips = paymentMethods.Sum(x => x.Tips),
            Refunds = refunds,
            NetRevenue = revenue - refunds,
            OrderCount = orderCount,
            GuestCount = totals?.Guests ?? 0,
            AverageBill = orderCount == 0 ? 0 : Money.Round(revenue / orderCount),
            CancelledOrderCount = cancelledOrders,
            Daily = EachDay(from, to)
                .Select(day => new DailySalesResponse
                {
                    Date = day,
                    Revenue = daily.TryGetValue(day, out var d) ? d.Revenue : 0,
                    OrderCount = daily.TryGetValue(day, out var o) ? o.Orders : 0
                })
                .ToList(),
            TopItems = topItems,
            LeastSoldItems = leastSold,
            Categories = categories,
            PaymentMethods = paymentMethods
                .OrderByDescending(x => x.Amount)
                .Select(x => new PaymentMethodSalesResponse { PaymentMethod = x.Method, PaymentCount = x.Count, Amount = x.Amount })
                .ToList()
        };
    }

    public async Task<StaffReportResponse> GetStaffReportAsync(ReportPeriodSearchObject period,
        CancellationToken cancellationToken = default)
    {
        var (from, to, fromUtc, toUtc) = Resolve(period);
        var settings = await settingsService.GetAsync(cancellationToken);

        var waiters = await context.Users
            .Where(x => x.Role.Name == Roles.Waiter)
            .Select(x => new { x.Id, Name = x.FirstName + " " + x.LastName, x.IsActive })
            .ToListAsync(cancellationToken);

        var orders = await PaidOrders(fromUtc, toUtc)
            .GroupBy(x => x.WaiterId)
            .Select(g => new { WaiterId = g.Key, Orders = g.Count(), Guests = g.Sum(x => x.GuestCount), Revenue = g.Sum(x => x.Total) })
            .ToDictionaryAsync(x => x.WaiterId, cancellationToken);

        var tips = await context.Payments
            .Where(x => PaidStatuses.Contains(x.Status) && x.CompletedAt >= fromUtc && x.CompletedAt < toUtc)
            .GroupBy(x => x.ProcessedByUserId)
            .Select(g => new { UserId = g.Key, Tips = g.Sum(x => x.TipAmount) })
            .ToDictionaryAsync(x => x.UserId, x => x.Tips, cancellationToken);

        var suggestions = await context.RecommendationEvents
            .Where(x => x.CreatedAt >= fromUtc && x.CreatedAt < toUtc)
            .GroupBy(x => x.WaiterId)
            .Select(g => new { WaiterId = g.Key, Shown = g.Count(), Accepted = g.Count(x => x.WasAccepted) })
            .ToDictionaryAsync(x => x.WaiterId, cancellationToken);

        var stations = await context.OrderTickets
            .Where(x => x.ReadyAt != null && x.ReadyAt >= fromUtc && x.ReadyAt < toUtc)
            .GroupBy(x => x.Station.Name)
            .Select(g => new StationPerformanceResponse
            {
                StationName = g.Key,
                TicketCount = g.Count(),
                AverageMinutesToStart = g.Average(x => (x.StartedAt!.Value - x.CreatedAt).TotalMinutes),
                AverageMinutesToReady = g.Average(x => (x.ReadyAt!.Value - x.CreatedAt).TotalMinutes)
            })
            .OrderBy(x => x.StationName)
            .ToListAsync(cancellationToken);

        foreach (var station in stations)
        {
            station.AverageMinutesToStart = RoundMinutes(station.AverageMinutesToStart);
            station.AverageMinutesToReady = RoundMinutes(station.AverageMinutesToReady);
        }

        return new StaffReportResponse
        {
            From = from,
            To = to,
            CurrencySymbol = settings.CurrencySymbol,
            Waiters = waiters
                .Select(w =>
                {
                    var o = orders.GetValueOrDefault(w.Id);
                    var s = suggestions.GetValueOrDefault(w.Id);
                    return new WaiterPerformanceResponse
                    {
                        UserId = w.Id,
                        Name = w.Name,
                        IsActive = w.IsActive,
                        OrderCount = o?.Orders ?? 0,
                        GuestCount = o?.Guests ?? 0,
                        Revenue = o?.Revenue ?? 0,
                        AverageBill = o is null || o.Orders == 0 ? 0 : Money.Round(o.Revenue / o.Orders),
                        Tips = tips.GetValueOrDefault(w.Id),
                        SuggestionsShown = s?.Shown ?? 0,
                        SuggestionsAccepted = s?.Accepted ?? 0,
                        SuggestionAcceptanceRate = s is null || s.Shown == 0 ? null : Math.Round((double)s.Accepted / s.Shown, 3)
                    };
                })
                .OrderByDescending(x => x.Revenue)
                .ToList(),
            Stations = stations
        };
    }

    public async Task<byte[]> GetSalesReportPdfAsync(ReportPeriodSearchObject period, CancellationToken cancellationToken = default)
    {
        var report = await GetSalesReportAsync(period, cancellationToken);
        var settings = await settingsService.GetAsync(cancellationToken);
        return new SalesReportDocument(report, settings.RestaurantName, clock.FormatLocal(clock.UtcNow)).GeneratePdf();
    }

    public async Task<byte[]> GetStaffReportPdfAsync(ReportPeriodSearchObject period, CancellationToken cancellationToken = default)
    {
        var report = await GetStaffReportAsync(period, cancellationToken);
        var settings = await settingsService.GetAsync(cancellationToken);
        return new StaffReportDocument(report, settings.RestaurantName, clock.FormatLocal(clock.UtcNow)).GeneratePdf();
    }

    private IQueryable<Order> PaidOrders(DateTime fromUtc, DateTime toUtc) =>
        context.Orders.Where(x => x.Status == OrderStatus.Completed && x.ClosedAt >= fromUtc && x.ClosedAt < toUtc);

    /// <summary>Items that were actually charged: items on cancelled tickets are not sales.</summary>
    private IQueryable<OrderItem> SoldItems(IQueryable<Order> paidOrders) =>
        context.OrderItems.Where(x => x.OrderTicket.Status != TicketStatus.Cancelled && paidOrders.Contains(x.Order));

    private (DateOnly From, DateOnly To, DateTime FromUtc, DateTime ToUtc) Resolve(ReportPeriodSearchObject period)
    {
        var today = DateOnly.FromDateTime(clock.ToLocal(clock.UtcNow));
        var to = period.To ?? today;
        var from = period.From ?? to.AddDays(-(DefaultPeriodDays - 1));

        return (from, to,
            clock.ToUtc(from.ToDateTime(TimeOnly.MinValue)),
            clock.ToUtc(to.AddDays(1).ToDateTime(TimeOnly.MinValue)));
    }

    private static IEnumerable<DateOnly> EachDay(DateOnly from, DateOnly to)
    {
        for (var day = from; day <= to; day = day.AddDays(1))
        {
            yield return day;
        }
    }

    private static double? RoundMinutes(double? minutes) => minutes is null ? null : Math.Round(minutes.Value, 1);
}
