using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Localization;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;
using Servio.Services.Common;
using Servio.Services.Database.Entities;
using Servio.Services.Database;
using Servio.Services.Notifications;

namespace Servio.Services.Tables;

/// <summary>
/// Tables with their live status: Occupied when an order is open, Reserved when a confirmed
/// reservation starts within the hold window, otherwise Available.
/// </summary>
public class RestaurantTableService(ServioDbContext context, INotificationDispatcher dispatcher)
    : BaseCrudService<RestaurantTable, RestaurantTableResponse, RestaurantTableSearchObject, RestaurantTableUpsertRequest, RestaurantTableUpsertRequest>(context),
        IRestaurantTableService
{
    protected override string EntityName => "Table";

    protected override Expression<Func<RestaurantTable, RestaurantTableResponse>> Projection
    {
        get
        {
            var now = DateTime.UtcNow;
            var reservedFrom = now + TableRules.ReservedHoldBeforeStart;

            return x => new RestaurantTableResponse
            {
                Id = x.Id,
                Number = x.Number,
                Capacity = x.Capacity,
                AreaId = x.AreaId,
                AreaName = x.Area.Name,
                IsActive = x.IsActive,
                AssignedWaiterId = x.AssignedWaiterId,
                AssignedWaiterName = x.AssignedWaiter == null ? null : x.AssignedWaiter.FirstName + " " + x.AssignedWaiter.LastName,
                Status = x.Orders.Any(o => o.Status == OrderStatus.Open)
                    ? TableStatus.Occupied
                    : x.Reservations.Any(r => r.Status == ReservationStatus.Confirmed && r.StartTime <= reservedFrom && r.EndTime > now)
                        ? TableStatus.Reserved
                        : TableStatus.Available,
                CurrentOrderId = x.Orders.Where(o => o.Status == OrderStatus.Open).Select(o => (int?)o.Id).FirstOrDefault(),
                CurrentOrderTotal = x.Orders.Where(o => o.Status == OrderStatus.Open).Select(o => (decimal?)o.Total).FirstOrDefault(),
                CurrentGuestCount = x.Orders.Where(o => o.Status == OrderStatus.Open).Select(o => (int?)o.GuestCount).FirstOrDefault(),
                UpcomingReservation = x.Reservations
                    .Where(r => r.Status == ReservationStatus.Confirmed && r.EndTime > now)
                    .OrderBy(r => r.StartTime)
                    .Select(r => new UpcomingReservationResponse
                    {
                        Id = r.Id,
                        GuestName = r.GuestName,
                        PartySize = r.PartySize,
                        StartTime = r.StartTime,
                        EndTime = r.EndTime
                    })
                    .FirstOrDefault(),
                HasHistory = x.Orders.Any() || x.Reservations.Any()
            };
        }
    }

    protected override IQueryable<RestaurantTable> ApplyFilter(IQueryable<RestaurantTable> query, RestaurantTableSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts && int.TryParse(fts, out var number))
        {
            query = query.Where(x => x.Number == number);
        }

        if (search.AreaId is { } areaId)
        {
            query = query.Where(x => x.AreaId == areaId);
        }

        if (search.MinCapacity is { } minCapacity)
        {
            query = query.Where(x => x.Capacity >= minCapacity);
        }

        if (search.IsActive is { } isActive)
        {
            query = query.Where(x => x.IsActive == isActive);
        }

        if (search.Status is { } status)
        {
            var now = DateTime.UtcNow;
            var reservedFrom = now + TableRules.ReservedHoldBeforeStart;
            Expression<Func<RestaurantTable, bool>> occupied = x => x.Orders.Any(o => o.Status == OrderStatus.Open);
            Expression<Func<RestaurantTable, bool>> reserved = x => x.Reservations.Any(r =>
                r.Status == ReservationStatus.Confirmed && r.StartTime <= reservedFrom && r.EndTime > now);

            query = status switch
            {
                TableStatus.Occupied => query.Where(occupied),
                TableStatus.Reserved => query.Where(occupied.Not()).Where(reserved),
                _ => query.Where(occupied.Not()).Where(reserved.Not())
            };
        }

        return query;
    }

    protected override IQueryable<RestaurantTable> ApplyOrdering(IQueryable<RestaurantTable> query, RestaurantTableSearchObject search) =>
        query.OrderBy(x => x.Number);

    protected override void MapInsert(RestaurantTableUpsertRequest request, RestaurantTable entity) => Map(request, entity);
    protected override void MapUpdate(RestaurantTableUpsertRequest request, RestaurantTable entity) => Map(request, entity);

    protected override Task BeforeInsertAsync(RestaurantTableUpsertRequest request, RestaurantTable entity, CancellationToken cancellationToken) =>
        ValidateAsync(entity, cancellationToken);

    protected override async Task BeforeUpdateAsync(RestaurantTableUpsertRequest request, RestaurantTable entity, CancellationToken cancellationToken)
    {
        await ValidateAsync(entity, cancellationToken);

        if (!entity.IsActive && await Context.Orders.AnyAsync(x => x.TableId == entity.Id && x.Status == OrderStatus.Open, cancellationToken))
        {
            throw new BusinessException("Table {0} has an open order. Close the order before deactivating the table.", entity.Number);
        }

        var largestUpcomingParty = await Context.Reservations
            .Where(x => x.TableId == entity.Id && x.EndTime > DateTime.UtcNow
                        && (x.Status == ReservationStatus.Pending || x.Status == ReservationStatus.Confirmed))
            .MaxAsync(x => (int?)x.PartySize, cancellationToken);
        if (largestUpcomingParty > entity.Capacity)
        {
            throw new BusinessException(
                "Table {0} has an upcoming reservation for {1} guests, so its capacity cannot be lower than that.", entity.Number, largestUpcomingParty);
        }
    }

    protected override async Task BeforeDeleteAsync(RestaurantTable entity, CancellationToken cancellationToken)
    {
        if (await Context.Orders.AnyAsync(x => x.TableId == entity.Id, cancellationToken)
            || await Context.Reservations.AnyAsync(x => x.TableId == entity.Id, cancellationToken))
        {
            throw new BusinessException(
                "Table {0} has orders or reservations in its history and cannot be deleted. Deactivate it instead.", entity.Number);
        }
    }

    public override async Task<RestaurantTableResponse> InsertAsync(RestaurantTableUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var response = await base.InsertAsync(request, cancellationToken);
        await PublishTablesChangedAsync(cancellationToken);
        return response;
    }

    public override async Task<RestaurantTableResponse> UpdateAsync(int id, RestaurantTableUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var response = await base.UpdateAsync(id, request, cancellationToken);
        await PublishTablesChangedAsync(cancellationToken);
        return response;
    }

    public override async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
    {
        await base.DeleteAsync(id, cancellationToken);
        await PublishTablesChangedAsync(cancellationToken);
    }

    public async Task AssignAsync(TableAssignmentsRequest request, CancellationToken cancellationToken = default)
    {
        // The last entry wins when the same table appears twice.
        var wanted = request.Items
            .GroupBy(x => x.TableId!.Value)
            .ToDictionary(g => g.Key, g => g.Last().WaiterId);

        var tables = await Context.RestaurantTables
            .Where(x => wanted.Keys.Contains(x.Id))
            .ToListAsync(cancellationToken);
        if (tables.Count != wanted.Count)
        {
            throw new BusinessException("Some of the selected tables no longer exist. Reload and try again.");
        }

        var waiterIds = wanted.Values.OfType<int>().Distinct().ToList();
        var validWaiters = await Context.Users
            .Where(x => waiterIds.Contains(x.Id) && x.IsActive && x.Role.Name == Roles.Waiter)
            .Select(x => x.Id)
            .ToListAsync(cancellationToken);
        if (validWaiters.Count != waiterIds.Count)
        {
            throw new BusinessException("Tables can only be assigned to active waiters.");
        }

        var gained = new Dictionary<int, List<int>>();
        foreach (var table in tables.OrderBy(x => x.Number))
        {
            var waiterId = wanted[table.Id];
            if (table.AssignedWaiterId == waiterId)
            {
                continue;
            }

            table.AssignedWaiterId = waiterId;
            if (waiterId is not { } newWaiter)
            {
                continue;
            }

            // The new waiter takes over a guest already sitting there: serving, billing and "ready" notifications.
            await Context.Orders
                .Where(x => x.TableId == table.Id && x.Status == OrderStatus.Open)
                .ForEachAsync(x => x.WaiterId = newWaiter, cancellationToken);

            if (!gained.TryGetValue(newWaiter, out var numbers))
            {
                gained[newWaiter] = numbers = [];
            }

            numbers.Add(table.Number);
        }

        foreach (var (waiterId, numbers) in gained)
        {
            await dispatcher.NotifyAsync(waiterId, NotificationType.TablesAssigned,
                new LocalizedText("New tables assigned"),
                new LocalizedText("You now serve tables {0}.", string.Join(", ", numbers)),
                cancellationToken: cancellationToken);
        }

        await Context.SaveChangesAsync(cancellationToken);
        await PublishTablesChangedAsync(cancellationToken);
    }

    private static void Map(RestaurantTableUpsertRequest request, RestaurantTable entity)
    {
        entity.Number = request.Number!.Value;
        entity.Capacity = request.Capacity!.Value;
        entity.AreaId = request.AreaId!.Value;
        entity.IsActive = request.IsActive;
    }

    private async Task ValidateAsync(RestaurantTable entity, CancellationToken cancellationToken)
    {
        if (!await Context.TableAreas.AnyAsync(x => x.Id == entity.AreaId, cancellationToken))
        {
            throw new BusinessException("The selected area does not exist.");
        }

        if (await Context.RestaurantTables.AnyAsync(x => x.Id != entity.Id && x.Number == entity.Number, cancellationToken))
        {
            throw new BusinessException("Table number {0} is already used by another table.", entity.Number);
        }
    }

    private Task PublishTablesChangedAsync(CancellationToken cancellationToken)
    {
        dispatcher.Broadcast(RealtimeEvents.OrdersChanged);
        return dispatcher.FlushAsync(cancellationToken);
    }
}
