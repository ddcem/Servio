using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Localization;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Common;
using Servio.Services.Database.Entities;
using Servio.Services.Database;
using Servio.Services.Notifications;
using Servio.Services.StateMachines;
using Servio.Services.Tables;

namespace Servio.Services.Orders;

/// <summary>
/// Kitchen and bar displays. Station staff see and change only their own station's tickets;
/// the admin watches every station in view-only mode.
/// </summary>
public class OrderTicketService(
    ServioDbContext context,
    ICurrentUserService currentUser,
    INotificationDispatcher dispatcher,
    IRestaurantClock clock)
    : BaseReadService<OrderTicket, OrderTicketResponse, OrderTicketSearchObject>(context), IOrderTicketService
{
    protected override string EntityName => "Ticket";

    /// <summary>The station a Kitchen or Bar user works at; station names match those role names.</summary>
    private string? OwnStationName =>
        currentUser.IsInRole(Roles.Kitchen) ? PreparationStations.Kitchen
        : currentUser.IsInRole(Roles.Bar) ? PreparationStations.Bar
        : null;

    protected override IQueryable<OrderTicket> Query =>
        OwnStationName is { } station
            ? Context.OrderTickets.Where(x => x.Station.Name == station)
            : Context.OrderTickets;

    protected override Expression<Func<OrderTicket, OrderTicketResponse>> Projection => x => new OrderTicketResponse
    {
        Id = x.Id,
        TicketNumber = x.TicketNumber,
        OrderId = x.OrderId,
        OrderNumber = x.Order.OrderNumber,
        TableNumber = x.Order.Table.Number,
        WaiterName = x.Order.Waiter.FirstName + " " + x.Order.Waiter.LastName,
        StationId = x.StationId,
        StationName = x.Station.Name,
        Status = x.Status,
        CreatedAt = x.CreatedAt,
        StartedAt = x.StartedAt,
        ReadyAt = x.ReadyAt,
        ServedAt = x.ServedAt,
        Items = x.Items
            .OrderBy(i => i.Id)
            .Select(i => new OrderTicketItemResponse
            {
                MenuItemId = i.MenuItemId,
                MenuItemName = i.MenuItem.Name,
                Quantity = i.Quantity,
                Note = i.Note
            })
            .ToList()
    };

    protected override IQueryable<OrderTicket> ApplyFilter(IQueryable<OrderTicket> query, OrderTicketSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            query = int.TryParse(fts, out var tableNumber)
                ? query.Where(x => x.Order.Table.Number == tableNumber)
                : query.Where(x => EF.Functions.ILike(x.TicketNumber, ContainsPattern(fts)));
        }

        if (search.StationId is { } stationId)
        {
            query = query.Where(x => x.StationId == stationId);
        }

        if (search.OrderId is { } orderId)
        {
            query = query.Where(x => x.OrderId == orderId);
        }

        if (search.Status is { } status)
        {
            query = query.Where(x => x.Status == status);
        }

        if (search.ActiveOnly)
        {
            query = query.Where(x => x.Status == TicketStatus.New || x.Status == TicketStatus.Preparing);
        }

        return query;
    }

    /// <summary>Oldest first: stations work through tickets in the order they arrived.</summary>
    protected override IQueryable<OrderTicket> ApplyOrdering(IQueryable<OrderTicket> query, OrderTicketSearchObject search) =>
        query.OrderBy(x => x.CreatedAt).ThenBy(x => x.Id);

    public async Task<OrderTicketResponse> StartAsync(int id, CancellationToken cancellationToken = default)
    {
        var ticket = await LoadForStationAsync(id, cancellationToken);
        ChangeStatus(ticket, TicketStatus.Preparing, null);
        ticket.StartedAt = DateTime.UtcNow;
        ticket.StartedByUserId = currentUser.UserId;

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<OrderTicketResponse> MarkReadyAsync(int id, CancellationToken cancellationToken = default)
    {
        var ticket = await LoadForStationAsync(id, cancellationToken);
        ChangeStatus(ticket, TicketStatus.Ready, null);
        ticket.ReadyAt = DateTime.UtcNow;
        ticket.ReadyByUserId = currentUser.UserId;

        var atBar = ticket.Station.Name == PreparationStations.Bar;
        await dispatcher.NotifyAsync(ticket.Order.WaiterId, NotificationType.TicketReady,
            new LocalizedText(atBar ? "Table {0} – drinks ready" : "Table {0} – food ready", ticket.Order.Table.Number),
            new LocalizedText(atBar ? "Ready at the bar: {0} (ticket {1})." : "Ready in the kitchen: {0} (ticket {1}).",
                DescribeItems(ticket), ticket.TicketNumber),
            ticket: ticket, cancellationToken: cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<OrderTicketResponse> ServeAsync(int id, CancellationToken cancellationToken = default)
    {
        var ticket = await LoadAsync(id, cancellationToken);
        await TableAccess.EnsureCanServeAsync(Context, currentUser, ticket.Order.Table, cancellationToken);
        ChangeStatus(ticket, TicketStatus.Served, null);
        ticket.ServedAt = DateTime.UtcNow;

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<OrderTicketResponse> CancelAsync(int id, ReasonRequest request, CancellationToken cancellationToken = default)
    {
        var ticket = await LoadAsync(id, cancellationToken);
        await TableAccess.EnsureCanServeAsync(Context, currentUser, ticket.Order.Table, cancellationToken);
        if (ticket.Order.Status != OrderStatus.Open)
        {
            throw new BusinessException("Order {0} is already closed.", ticket.Order.OrderNumber);
        }

        if (ticket.Status != TicketStatus.New)
        {
            throw new BusinessException(
                "Ticket {0} is already {1} and can no longer be cancelled.", ticket.TicketNumber, ticket.Status);
        }

        var reason = request.Reason.Trim();
        ChangeStatus(ticket, TicketStatus.Cancelled, reason);

        await Context.Entry(ticket.Order).Collection(x => x.Items).Query().Include(x => x.OrderTicket).LoadAsync(cancellationToken);
        OrderCalculator.Recalculate(ticket.Order);

        await dispatcher.NotifyRoleAsync(ticket.Station.Name, NotificationType.TicketCancelled,
            new LocalizedText("Ticket {0} cancelled – table {1}", ticket.TicketNumber, ticket.Order.Table.Number),
            new LocalizedText("{0}. Reason: {1}", DescribeItems(ticket), reason),
            ticket: ticket, cancellationToken: cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<List<StationSummaryResponse>> GetStationSummariesAsync(CancellationToken cancellationToken = default)
    {
        var todayStart = clock.TodayStartUtc;

        var active = await Context.OrderTickets
            .Where(x => x.Status == TicketStatus.New || x.Status == TicketStatus.Preparing)
            .GroupBy(x => x.StationId)
            .Select(g => new
            {
                StationId = g.Key,
                NewCount = g.Count(x => x.Status == TicketStatus.New),
                PreparingCount = g.Count(x => x.Status == TicketStatus.Preparing),
                OldestWaitingSince = g.Min(x => (DateTime?)x.CreatedAt)
            })
            .ToDictionaryAsync(x => x.StationId, cancellationToken);

        var finishedToday = await Context.OrderTickets
            .Where(x => x.ReadyAt != null && x.ReadyAt >= todayStart)
            .Select(x => new { x.StationId, x.CreatedAt, ReadyAt = x.ReadyAt!.Value })
            .ToListAsync(cancellationToken);

        var stations = await Context.PreparationStations.OrderBy(x => x.Id).ToListAsync(cancellationToken);

        return stations.Select(station =>
        {
            active.TryGetValue(station.Id, out var counts);
            var finished = finishedToday.Where(x => x.StationId == station.Id).ToList();

            return new StationSummaryResponse
            {
                StationId = station.Id,
                StationName = station.Name,
                NewCount = counts?.NewCount ?? 0,
                PreparingCount = counts?.PreparingCount ?? 0,
                OldestWaitingSince = counts?.OldestWaitingSince,
                CompletedToday = finished.Count,
                AverageMinutesToReadyToday = finished.Count == 0
                    ? null
                    : Math.Round(finished.Average(x => (x.ReadyAt - x.CreatedAt).TotalMinutes), 1)
            };
        }).ToList();
    }

    private async Task<OrderTicket> LoadAsync(int id, CancellationToken cancellationToken) =>
        await Query
            .Include(x => x.Station)
            .Include(x => x.Order).ThenInclude(x => x.Table)
            .Include(x => x.Items).ThenInclude(x => x.MenuItem)
            .FirstOrDefaultAsync(x => x.Id == id, cancellationToken)
        ?? throw NotFound();

    /// <summary>Loads a ticket that the current kitchen/bar user is allowed to work on.</summary>
    private async Task<OrderTicket> LoadForStationAsync(int id, CancellationToken cancellationToken)
    {
        var ticket = await LoadAsync(id, cancellationToken);
        if (ticket.Station.Name != OwnStationName)
        {
            throw new ForbiddenException("You can only update tickets of your own station.");
        }

        return ticket;
    }

    private void ChangeStatus(OrderTicket ticket, TicketStatus to, string? reason)
    {
        StatusWorkflows.Ticket.EnsureCanTransition(ticket.Status, to);
        ticket.StatusHistory.Add(new OrderTicketStatusHistory
        {
            FromStatus = ticket.Status,
            ToStatus = to,
            ChangedByUserId = currentUser.UserId,
            Reason = reason,
            ChangedAt = DateTime.UtcNow
        });
        ticket.Status = to;
    }

    private static string DescribeItems(OrderTicket ticket) =>
        string.Join(", ", ticket.Items.OrderBy(x => x.Id).Select(x => $"{x.MenuItem.Name} ×{x.Quantity}"));

    private Task PublishChangesAsync(CancellationToken cancellationToken)
    {
        dispatcher.Broadcast(RealtimeEvents.TicketsChanged);
        dispatcher.Broadcast(RealtimeEvents.OrdersChanged);
        return dispatcher.FlushAsync(cancellationToken);
    }
}
