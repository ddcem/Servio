using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Common;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Notifications;
using Servio.Services.Settings;
using Servio.Services.StateMachines;

namespace Servio.Services.Orders;

/// <summary>
/// One order is one bill for a table visit. Every round of items is split into one ticket per
/// preparation station (kitchen, bar), and each ticket moves through its own workflow.
/// </summary>
public class OrderService(
    ServioDbContext context,
    ICurrentUserService currentUser,
    ISettingsService settingsService,
    INotificationDispatcher dispatcher,
    IRestaurantClock clock)
    : BaseReadService<Order, OrderResponse, OrderSearchObject>(context), IOrderService
{
    private static readonly PaymentStatus[] PaidStatuses =
        [PaymentStatus.Completed, PaymentStatus.PartiallyRefunded, PaymentStatus.Refunded];

    protected override string EntityName => "Order";

    protected override Expression<Func<Order, OrderResponse>> Projection => x => new OrderResponse
    {
        Id = x.Id,
        OrderNumber = x.OrderNumber,
        TableId = x.TableId,
        TableNumber = x.Table.Number,
        GuestCount = x.GuestCount,
        WaiterId = x.WaiterId,
        WaiterName = x.Waiter.FirstName + " " + x.Waiter.LastName,
        Status = x.Status,
        Subtotal = x.Subtotal,
        TaxRate = x.TaxRate,
        TaxAmount = x.TaxAmount,
        Total = x.Total,
        CurrencyCode = x.Currency.Code,
        CurrencySymbol = x.Currency.Symbol,
        OpenedAt = x.OpenedAt,
        ClosedAt = x.ClosedAt,
        CancellationReason = x.CancellationReason,
        IsPaid = x.Payments.Any(p => PaidStatuses.Contains(p.Status)),
        Items = x.Items
            .OrderBy(i => i.Id)
            .Select(i => new OrderItemResponse
            {
                Id = i.Id,
                MenuItemId = i.MenuItemId,
                MenuItemName = i.MenuItem.Name,
                Quantity = i.Quantity,
                UnitPrice = i.UnitPrice,
                LineTotal = Math.Round(i.UnitPrice * i.Quantity, 2),
                Note = i.Note,
                OrderTicketId = i.OrderTicketId,
                TicketStatus = i.OrderTicket.Status
            })
            .ToList(),
        Tickets = x.Tickets
            .OrderBy(t => t.CreatedAt)
            .Select(t => new OrderTicketSummaryResponse
            {
                Id = t.Id,
                TicketNumber = t.TicketNumber,
                StationName = t.Station.Name,
                Status = t.Status,
                CreatedAt = t.CreatedAt
            })
            .ToList()
    };

    protected override IQueryable<Order> ApplyFilter(IQueryable<Order> query, OrderSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            query = int.TryParse(fts, out var tableNumber)
                ? query.Where(x => x.Table.Number == tableNumber || EF.Functions.ILike(x.OrderNumber, ContainsPattern(fts)))
                : query.Where(x => EF.Functions.ILike(x.OrderNumber, ContainsPattern(fts)));
        }

        if (search.TableId is { } tableId)
        {
            query = query.Where(x => x.TableId == tableId);
        }

        if (search.MyOrdersOnly)
        {
            var userId = currentUser.UserId;
            query = query.Where(x => x.WaiterId == userId);
        }
        else if (search.WaiterId is { } waiterId)
        {
            query = query.Where(x => x.WaiterId == waiterId);
        }

        if (search.Status is { } status)
        {
            query = query.Where(x => x.Status == status);
        }

        if (search.From.AsUtc() is { } from)
        {
            query = query.Where(x => x.OpenedAt >= from);
        }

        if (search.To.AsUtc() is { } to)
        {
            query = query.Where(x => x.OpenedAt <= to);
        }

        return query;
    }

    protected override IQueryable<Order> ApplyOrdering(IQueryable<Order> query, OrderSearchObject search) =>
        query.OrderByDescending(x => x.OpenedAt).ThenByDescending(x => x.Id);

    public async Task<OrderResponse> CreateAsync(OrderCreateRequest request, CancellationToken cancellationToken = default)
    {
        var table = await Context.RestaurantTables.FirstOrDefaultAsync(x => x.Id == request.TableId, cancellationToken)
                    ?? throw new NotFoundException("The selected table was not found.");

        if (!table.IsActive)
        {
            throw new BusinessException($"Table {table.Number} is not in use.");
        }

        if (request.GuestCount > table.Capacity)
        {
            throw new BusinessException($"Table {table.Number} seats at most {table.Capacity} guests.");
        }

        if (await Context.Orders.AnyAsync(x => x.TableId == table.Id && x.Status == OrderStatus.Open, cancellationToken))
        {
            throw new BusinessException($"Table {table.Number} already has an open order. Add the items to that order instead.");
        }

        var settings = await settingsService.GetAsync(cancellationToken);
        var now = DateTime.UtcNow;

        var order = new Order
        {
            OrderNumber = await NextOrderNumberAsync(cancellationToken),
            Table = table,
            GuestCount = request.GuestCount!.Value,
            WaiterId = currentUser.UserId,
            Status = OrderStatus.Open,
            TaxRate = settings.TaxRate,
            CurrencyId = settings.CurrencyId,
            OpenedAt = now
        };

        var roundItemIds = await AddRoundAsync(order, request.Items, cancellationToken);
        await RecordShownRecommendationsAsync(order, request.ShownRecommendations, roundItemIds, cancellationToken);
        Context.Orders.Add(order);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(order.Id, cancellationToken);
    }

    public async Task<OrderResponse> AddItemsAsync(int id, OrderAddItemsRequest request, CancellationToken cancellationToken = default)
    {
        var order = await LoadWithItemsAsync(id, cancellationToken);
        EnsureOpen(order);

        var roundItemIds = await AddRoundAsync(order, request.Items, cancellationToken);
        await RecordShownRecommendationsAsync(order, request.ShownRecommendations, roundItemIds, cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(order.Id, cancellationToken);
    }

    public async Task<OrderResponse> CancelAsync(int id, ReasonRequest request, CancellationToken cancellationToken = default)
    {
        var order = await LoadWithItemsAsync(id, cancellationToken);
        await Context.Entry(order).Collection(x => x.Payments).LoadAsync(cancellationToken);

        if (order.Payments.Any(x => x.Status is PaymentStatus.Pending or PaymentStatus.Completed))
        {
            throw new BusinessException("This order has a payment in progress or completed. Use a refund instead of cancelling.");
        }

        if (order.Tickets.Any(x => x.Status is TicketStatus.Preparing or TicketStatus.Ready or TicketStatus.Served))
        {
            throw new BusinessException(
                "Some items are already being prepared or were served, so the order cannot be cancelled. It has to be paid.");
        }

        StatusWorkflows.Order.EnsureCanTransition(order.Status, OrderStatus.Cancelled);

        var reason = request.Reason.Trim();
        var now = DateTime.UtcNow;

        foreach (var ticket in order.Tickets.Where(x => x.Status == TicketStatus.New))
        {
            StatusWorkflows.Ticket.EnsureCanTransition(ticket.Status, TicketStatus.Cancelled);
            ticket.StatusHistory.Add(new OrderTicketStatusHistory
            {
                FromStatus = ticket.Status,
                ToStatus = TicketStatus.Cancelled,
                ChangedByUserId = currentUser.UserId,
                Reason = reason,
                ChangedAt = now
            });
            ticket.Status = TicketStatus.Cancelled;

            await dispatcher.NotifyRoleAsync(ticket.Station.Name, NotificationType.TicketCancelled,
                $"Ticket {ticket.TicketNumber} cancelled – table {order.Table.Number}",
                $"The whole order was cancelled. Reason: {reason}",
                ticket: ticket, cancellationToken: cancellationToken);
        }

        order.Status = OrderStatus.Cancelled;
        order.ClosedAt = now;
        order.CancelledByUserId = currentUser.UserId;
        order.CancellationReason = reason;
        OrderCalculator.Recalculate(order);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(order.Id, cancellationToken);
    }

    private async Task<Order> LoadWithItemsAsync(int id, CancellationToken cancellationToken) =>
        await Context.Orders
            .Include(x => x.Table)
            .Include(x => x.Items).ThenInclude(x => x.OrderTicket)
            .Include(x => x.Tickets).ThenInclude(x => x.Station)
            .AsSplitQuery()
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken)
        ?? throw NotFound();

    private static void EnsureOpen(Order order)
    {
        if (order.Status != OrderStatus.Open)
        {
            throw new BusinessException($"Order {order.OrderNumber} is {order.Status.ToString().ToLower()} and can no longer be changed.");
        }
    }

    /// <summary>
    /// Adds a round of items with prices taken from the menu (never from the client) and creates
    /// one ticket per preparation station that has items in this round. Returns the menu items of the round.
    /// </summary>
    private async Task<HashSet<int>> AddRoundAsync(Order order, List<OrderItemRequest> lines, CancellationToken cancellationToken)
    {
        var menuItemIds = lines.Select(x => x.MenuItemId!.Value).Distinct().ToList();
        var menuItems = await Context.MenuItems
            .Where(x => menuItemIds.Contains(x.Id) && !x.IsDeleted)
            .Select(x => new
            {
                x.Id,
                x.Name,
                x.Price,
                x.IsAvailableToday,
                StationId = x.Category.PreparationStationId,
                StationName = x.Category.PreparationStation.Name
            })
            .ToDictionaryAsync(x => x.Id, cancellationToken);

        if (menuItems.Count != menuItemIds.Count)
        {
            throw new BusinessException("Some items were removed from the menu. Reload the menu and try again.");
        }

        var unavailable = menuItems.Values.Where(x => !x.IsAvailableToday).Select(x => x.Name).ToList();
        if (unavailable.Count > 0)
        {
            throw new BusinessException($"Not available today: {string.Join(", ", unavailable)}. Remove them from the order.");
        }

        var now = DateTime.UtcNow;
        foreach (var stationGroup in lines.GroupBy(x => menuItems[x.MenuItemId!.Value].StationId))
        {
            var stationName = menuItems[stationGroup.First().MenuItemId!.Value].StationName;
            var ticket = new OrderTicket
            {
                Order = order,
                StationId = stationGroup.Key,
                TicketNumber = await NextTicketNumberAsync(stationGroup.Key, stationName, cancellationToken),
                Status = TicketStatus.New,
                CreatedAt = now
            };
            ticket.StatusHistory.Add(new OrderTicketStatusHistory
            {
                ToStatus = TicketStatus.New,
                ChangedByUserId = currentUser.UserId,
                ChangedAt = now
            });
            order.Tickets.Add(ticket);

            foreach (var line in stationGroup)
            {
                var menuItem = menuItems[line.MenuItemId!.Value];
                order.Items.Add(new OrderItem
                {
                    Order = order,
                    OrderTicket = ticket,
                    MenuItemId = menuItem.Id,
                    Quantity = line.Quantity!.Value,
                    UnitPrice = menuItem.Price,
                    Note = Normalize(line.Note)
                });
            }
        }

        OrderCalculator.Recalculate(order);
        return menuItemIds.ToHashSet();
    }

    /// <summary>
    /// Stores the suggestions the waiter saw as recommender feedback. A suggestion counts as accepted
    /// only if its item is really part of this round, so the client cannot fake acceptance.
    /// </summary>
    private async Task RecordShownRecommendationsAsync(Order order, List<ShownRecommendationRequest> shown,
        HashSet<int> roundItemIds, CancellationToken cancellationToken)
    {
        var distinct = shown
            .DistinctBy(x => (x.SourceMenuItemId, x.RecommendedMenuItemId))
            .Where(x => x.SourceMenuItemId != x.RecommendedMenuItemId)
            .ToList();
        if (distinct.Count == 0)
        {
            return;
        }

        var referencedIds = distinct.SelectMany(x => new[] { x.SourceMenuItemId!.Value, x.RecommendedMenuItemId!.Value })
            .Distinct().ToList();
        var existingIds = (await Context.MenuItems.Where(x => referencedIds.Contains(x.Id)).Select(x => x.Id)
            .ToListAsync(cancellationToken)).ToHashSet();

        var now = DateTime.UtcNow;
        foreach (var suggestion in distinct.Where(x => existingIds.Contains(x.SourceMenuItemId!.Value)
                                                       && existingIds.Contains(x.RecommendedMenuItemId!.Value)))
        {
            Context.RecommendationEvents.Add(new RecommendationEvent
            {
                Order = order,
                WaiterId = currentUser.UserId,
                SourceMenuItemId = suggestion.SourceMenuItemId!.Value,
                RecommendedMenuItemId = suggestion.RecommendedMenuItemId!.Value,
                Score = Math.Round(suggestion.Score, 4),
                Reason = suggestion.Reason.Trim(),
                WasAccepted = roundItemIds.Contains(suggestion.RecommendedMenuItemId!.Value),
                CreatedAt = now
            });
        }
    }

    /// <summary>Human-readable number that restarts every business day, e.g. 20261005-0012.</summary>
    private async Task<string> NextOrderNumberAsync(CancellationToken cancellationToken)
    {
        var todayStart = clock.TodayStartUtc;
        var countToday = await Context.Orders.CountAsync(x => x.OpenedAt >= todayStart, cancellationToken);
        return $"{clock.ToLocal(DateTime.UtcNow):yyyyMMdd}-{countToday + 1:0000}";
    }

    /// <summary>Station prefix plus a daily counter, e.g. K001 for the kitchen, B001 for the bar.</summary>
    private async Task<string> NextTicketNumberAsync(int stationId, string stationName, CancellationToken cancellationToken)
    {
        var todayStart = clock.TodayStartUtc;
        var countToday = await Context.OrderTickets
            .CountAsync(x => x.StationId == stationId && x.CreatedAt >= todayStart, cancellationToken);
        return $"{char.ToUpperInvariant(stationName[0])}{countToday + 1:000}";
    }

    private Task PublishChangesAsync(CancellationToken cancellationToken)
    {
        dispatcher.Broadcast(RealtimeEvents.OrdersChanged);
        dispatcher.Broadcast(RealtimeEvents.TicketsChanged);
        return dispatcher.FlushAsync(cancellationToken);
    }
}
