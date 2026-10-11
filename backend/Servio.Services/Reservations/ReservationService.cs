using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Localization;
using Servio.Model.Messages;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Common;
using Servio.Services.Database.Entities;
using Servio.Services.Database;
using Servio.Services.Localization;
using Servio.Services.Messaging;
using Servio.Services.Notifications;
using Servio.Services.Settings;
using Servio.Services.StateMachines;

namespace Servio.Services.Reservations;

public class ReservationService(
    ServioDbContext context,
    ICurrentUserService currentUser,
    INotificationDispatcher dispatcher,
    IMessagePublisher messagePublisher,
    ISettingsService settingsService,
    IRestaurantClock clock,
    ILogger<ReservationService> logger)
    : BaseReadService<Reservation, ReservationResponse, ReservationSearchObject>(context), IReservationService
{
    private static readonly ReservationStatus[] ActiveStatuses = [ReservationStatus.Pending, ReservationStatus.Confirmed];

    protected override string EntityName => "Reservation";

    protected override Expression<Func<Reservation, ReservationResponse>> Projection => x => new ReservationResponse
    {
        Id = x.Id,
        TableId = x.TableId,
        TableNumber = x.Table.Number,
        GuestName = x.GuestName,
        GuestPhone = x.GuestPhone,
        GuestEmail = x.GuestEmail,
        PartySize = x.PartySize,
        StartTime = x.StartTime,
        EndTime = x.EndTime,
        Status = x.Status,
        Note = x.Note,
        CreatedByName = x.CreatedByUser.FirstName + " " + x.CreatedByUser.LastName,
        CreatedAt = x.CreatedAt
    };

    protected override Expression<Func<Reservation, ReservationResponse>> DetailsProjection => x => new ReservationResponse
    {
        Id = x.Id,
        TableId = x.TableId,
        TableNumber = x.Table.Number,
        GuestName = x.GuestName,
        GuestPhone = x.GuestPhone,
        GuestEmail = x.GuestEmail,
        PartySize = x.PartySize,
        StartTime = x.StartTime,
        EndTime = x.EndTime,
        Status = x.Status,
        Note = x.Note,
        CreatedByName = x.CreatedByUser.FirstName + " " + x.CreatedByUser.LastName,
        CreatedAt = x.CreatedAt,
        History = x.StatusHistory
            .OrderBy(h => h.ChangedAt)
            .Select(h => new StatusHistoryResponse
            {
                FromStatus = h.FromStatus.HasValue ? h.FromStatus.Value.ToString() : null,
                ToStatus = h.ToStatus.ToString(),
                ChangedByName = h.ChangedByUser.FirstName + " " + h.ChangedByUser.LastName,
                Reason = h.Reason,
                ChangedAt = h.ChangedAt
            })
            .ToList()
    };

    protected override IQueryable<Reservation> ApplyFilter(IQueryable<Reservation> query, ReservationSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            var pattern = ContainsPattern(fts);
            query = query.Where(x => EF.Functions.ILike(x.GuestName, pattern) || EF.Functions.ILike(x.GuestPhone, pattern));
        }

        if (search.TableId is { } tableId)
        {
            query = query.Where(x => x.TableId == tableId);
        }

        if (search.Status is { } status)
        {
            query = query.Where(x => x.Status == status);
        }

        if (search.From.AsUtc() is { } from)
        {
            query = query.Where(x => x.EndTime >= from);
        }

        if (search.To.AsUtc() is { } to)
        {
            query = query.Where(x => x.StartTime <= to);
        }

        return query;
    }

    protected override IQueryable<Reservation> ApplyOrdering(IQueryable<Reservation> query, ReservationSearchObject search) =>
        query.OrderByDescending(x => x.StartTime).ThenByDescending(x => x.Id);

    public async Task<ReservationResponse> InsertAsync(ReservationUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var reservation = new Reservation
        {
            Status = ReservationStatus.Pending,
            CreatedByUserId = currentUser.UserId,
            CreatedAt = DateTime.UtcNow
        };
        Map(request, reservation);

        var table = await ValidateAsync(reservation, startChanged: true, cancellationToken);
        AddHistory(reservation, null, ReservationStatus.Pending, null);
        Context.Reservations.Add(reservation);

        await dispatcher.NotifyRoleAsync(Roles.Waiter, NotificationType.ReservationCreated,
            new LocalizedText("New reservation – table {0}", table.Number),
            new LocalizedText("{0}, {1} guests, {2}. Waiting for confirmation.", reservation.GuestName, reservation.PartySize, Describe(reservation)),
            reservation: reservation, cancellationToken: cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(reservation.Id, cancellationToken);
    }

    public async Task<ReservationResponse> UpdateAsync(int id, ReservationUpsertRequest request, CancellationToken cancellationToken = default)
    {
        var reservation = await LoadAsync(id, cancellationToken);
        if (!ActiveStatuses.Contains(reservation.Status))
        {
            throw new BusinessException("A {0} reservation can no longer be edited.", reservation.Status);
        }

        Map(request, reservation);
        var startChanged = Context.Entry(reservation).Property(x => x.StartTime).IsModified;
        await ValidateAsync(reservation, startChanged, cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ReservationResponse> ConfirmAsync(int id, CancellationToken cancellationToken = default)
    {
        var reservation = await LoadAsync(id, cancellationToken);
        if (reservation.EndTime <= DateTime.UtcNow)
        {
            throw new BusinessException("This reservation has already ended and cannot be confirmed.");
        }

        ChangeStatus(reservation, ReservationStatus.Confirmed, null);

        await dispatcher.NotifyRoleAsync(Roles.Waiter, NotificationType.ReservationConfirmed,
            new LocalizedText("Table {0} reserved", reservation.Table.Number),
            new LocalizedText("{0}, {1} guests, {2}.", reservation.GuestName, reservation.PartySize, Describe(reservation)),
            reservation: reservation, cancellationToken: cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        if (reservation.GuestEmail is { } email)
        {
            var settings = await settingsService.GetAsync(cancellationToken);
            await TrySendEmailAsync(EmailTemplates.ReservationConfirmed(email, reservation.GuestName, settings.RestaurantName,
                reservation.Table.Number, reservation.PartySize,
                clock.FormatLocal(reservation.StartTime), clock.FormatLocal(reservation.EndTime, "HH:mm"), LanguageContext.Current), cancellationToken);
        }

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ReservationResponse> CompleteAsync(int id, CancellationToken cancellationToken = default)
    {
        var reservation = await LoadAsync(id, cancellationToken);
        if (DateTime.UtcNow < reservation.StartTime - ReservationRules.CompleteEarliestBeforeStart)
        {
            throw new BusinessException(
                "Guests can be marked as arrived at most {0:0} minutes before the reservation starts.", ReservationRules.CompleteEarliestBeforeStart.TotalMinutes);
        }

        ChangeStatus(reservation, ReservationStatus.Completed, null);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ReservationResponse> MarkNoShowAsync(int id, CancellationToken cancellationToken = default)
    {
        var reservation = await LoadAsync(id, cancellationToken);
        if (DateTime.UtcNow < reservation.StartTime + ReservationRules.NoShowGracePeriod)
        {
            throw new BusinessException(
                "A guest can be marked as a no-show only {0:0} minutes after the reservation starts.", ReservationRules.NoShowGracePeriod.TotalMinutes);
        }

        ChangeStatus(reservation, ReservationStatus.NoShow, null);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task<ReservationResponse> CancelAsync(int id, ReasonRequest request, CancellationToken cancellationToken = default)
    {
        var reservation = await LoadAsync(id, cancellationToken);
        var reason = request.Reason.Trim();

        ChangeStatus(reservation, ReservationStatus.Cancelled, reason);

        await dispatcher.NotifyRoleAsync(Roles.Waiter, NotificationType.ReservationCancelled,
            new LocalizedText("Reservation cancelled – table {0}", reservation.Table.Number),
            new LocalizedText("{0}, {1}. Reason: {2}", reservation.GuestName, Describe(reservation), reason),
            reservation: reservation, cancellationToken: cancellationToken);

        await Context.SaveChangesAsync(cancellationToken);
        await PublishChangesAsync(cancellationToken);

        if (reservation.GuestEmail is { } email)
        {
            var settings = await settingsService.GetAsync(cancellationToken);
            await TrySendEmailAsync(EmailTemplates.ReservationCancelled(email, reservation.GuestName, settings.RestaurantName,
                clock.FormatLocal(reservation.StartTime), reason, LanguageContext.Current), cancellationToken);
        }

        return await GetByIdAsync(id, cancellationToken);
    }

    private async Task<Reservation> LoadAsync(int id, CancellationToken cancellationToken) =>
        await Context.Reservations.Include(x => x.Table).FirstOrDefaultAsync(x => x.Id == id, cancellationToken)
        ?? throw NotFound();

    private void ChangeStatus(Reservation reservation, ReservationStatus to, string? reason)
    {
        StatusWorkflows.Reservation.EnsureCanTransition(reservation.Status, to);
        AddHistory(reservation, reservation.Status, to, reason);
        reservation.Status = to;
    }

    private void AddHistory(Reservation reservation, ReservationStatus? from, ReservationStatus to, string? reason) =>
        reservation.StatusHistory.Add(new ReservationStatusHistory
        {
            FromStatus = from,
            ToStatus = to,
            ChangedByUserId = currentUser.UserId,
            Reason = reason,
            ChangedAt = DateTime.UtcNow
        });

    private static void Map(ReservationUpsertRequest request, Reservation reservation)
    {
        reservation.TableId = request.TableId!.Value;
        reservation.GuestName = request.GuestName.Trim();
        reservation.GuestPhone = request.GuestPhone.Trim();
        reservation.GuestEmail = Normalize(request.GuestEmail);
        reservation.PartySize = request.PartySize!.Value;
        reservation.StartTime = request.StartTime!.Value.AsUtc();
        reservation.EndTime = request.EndTime!.Value.AsUtc();
        reservation.Note = Normalize(request.Note);
    }

    /// <summary>Checks time, capacity and double bookings on the server; returns the reserved table.</summary>
    private async Task<RestaurantTable> ValidateAsync(Reservation reservation, bool startChanged, CancellationToken cancellationToken)
    {
        var now = DateTime.UtcNow;
        var duration = reservation.EndTime - reservation.StartTime;

        if (duration <= TimeSpan.Zero)
        {
            throw new BusinessException("End time must be after the start time.");
        }

        if (duration < ReservationRules.MinDuration || duration > ReservationRules.MaxDuration)
        {
            throw new BusinessException(
                "A reservation must last between {0:0} minutes and {1:0} hours.", ReservationRules.MinDuration.TotalMinutes, ReservationRules.MaxDuration.TotalHours);
        }

        if (startChanged && reservation.StartTime < now - ReservationRules.PastStartTolerance)
        {
            throw new BusinessException("Start time must be in the future.");
        }

        if (reservation.StartTime > now + ReservationRules.MaxBookingAhead)
        {
            throw new BusinessException("Reservations can be made at most {0:0} days in advance.", ReservationRules.MaxBookingAhead.TotalDays);
        }

        var table = await Context.RestaurantTables.FirstOrDefaultAsync(x => x.Id == reservation.TableId, cancellationToken)
                    ?? throw new BusinessException("The selected table does not exist.");

        if (!table.IsActive)
        {
            throw new BusinessException("Table {0} is not in use and cannot be reserved.", table.Number);
        }

        if (reservation.PartySize > table.Capacity)
        {
            throw new BusinessException("Table {0} seats at most {1} guests. Choose a larger table.", table.Number, table.Capacity);
        }

        var overlapping = await Context.Reservations
            .Where(x => x.Id != reservation.Id
                        && x.TableId == reservation.TableId
                        && ActiveStatuses.Contains(x.Status)
                        && x.StartTime < reservation.EndTime
                        && x.EndTime > reservation.StartTime)
            .Select(x => new { x.StartTime, x.EndTime })
            .FirstOrDefaultAsync(cancellationToken);
        if (overlapping is not null)
        {
            throw new BusinessException(
                "Table {0} is already reserved from {1} to {2}.", table.Number, clock.FormatLocal(overlapping.StartTime), clock.FormatLocal(overlapping.EndTime, "HH:mm"));
        }

        var duplicateTable = await Context.Reservations
            .Where(x => x.Id != reservation.Id
                        && x.GuestPhone == reservation.GuestPhone
                        && ActiveStatuses.Contains(x.Status)
                        && x.StartTime < reservation.EndTime
                        && x.EndTime > reservation.StartTime)
            .Select(x => (int?)x.Table.Number)
            .FirstOrDefaultAsync(cancellationToken);
        if (duplicateTable is not null)
        {
            throw new BusinessException(
                "The guest with phone {0} already has a reservation at that time (table {1}).", reservation.GuestPhone, duplicateTable);
        }

        return table;
    }

    private string Describe(Reservation reservation) =>
        $"{clock.FormatLocal(reservation.StartTime)}–{clock.FormatLocal(reservation.EndTime, "HH:mm")}";

    private async Task PublishChangesAsync(CancellationToken cancellationToken)
    {
        dispatcher.Broadcast(RealtimeEvents.ReservationsChanged);
        dispatcher.Broadcast(RealtimeEvents.OrdersChanged);
        await dispatcher.FlushAsync(cancellationToken);
    }

    /// <summary>
    /// The reservation is already saved when the guest email is queued, so a broker outage
    /// is logged instead of failing the request.
    /// </summary>
    private async Task TrySendEmailAsync(EmailMessage message, CancellationToken cancellationToken)
    {
        try
        {
            await messagePublisher.PublishEmailAsync(message, cancellationToken);
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            logger.LogWarning(ex, "Reservation email '{Subject}' to {Email} could not be queued", message.Subject, message.ToEmail);
        }
    }
}
