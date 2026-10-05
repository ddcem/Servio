using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.Notifications;

public class NotificationService(ServioDbContext context, ICurrentUserService currentUser)
    : BaseReadService<Notification, NotificationResponse, NotificationSearchObject>(context), INotificationService
{
    protected override string EntityName => "Notification";

    protected override IQueryable<Notification> Query
    {
        get
        {
            var userId = currentUser.UserId;
            return Context.Notifications.Where(x => x.UserId == userId);
        }
    }

    protected override Expression<Func<Notification, NotificationResponse>> Projection => x => new NotificationResponse
    {
        Id = x.Id,
        Title = x.Title,
        Body = x.Body,
        Type = x.Type,
        IsRead = x.IsRead,
        CreatedAt = x.CreatedAt,
        OrderTicketId = x.OrderTicketId,
        ReservationId = x.ReservationId
    };

    protected override IQueryable<Notification> ApplyFilter(IQueryable<Notification> query, NotificationSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            var pattern = ContainsPattern(fts);
            query = query.Where(x => EF.Functions.ILike(x.Title, pattern) || EF.Functions.ILike(x.Body, pattern));
        }

        if (search.IsRead is { } isRead)
        {
            query = query.Where(x => x.IsRead == isRead);
        }

        return query;
    }

    protected override IQueryable<Notification> ApplyOrdering(IQueryable<Notification> query, NotificationSearchObject search) =>
        query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id);

    public async Task<UnreadCountResponse> GetUnreadCountAsync(CancellationToken cancellationToken = default) =>
        new(await Query.CountAsync(x => !x.IsRead, cancellationToken));

    public async Task<NotificationResponse> MarkAsReadAsync(int id, CancellationToken cancellationToken = default)
    {
        var notification = await Query.FirstOrDefaultAsync(x => x.Id == id, cancellationToken) ?? throw NotFound();
        notification.IsRead = true;
        await Context.SaveChangesAsync(cancellationToken);
        return await GetByIdAsync(id, cancellationToken);
    }

    public async Task MarkAllAsReadAsync(CancellationToken cancellationToken = default) =>
        await Query.Where(x => !x.IsRead).ExecuteUpdateAsync(s => s.SetProperty(x => x.IsRead, true), cancellationToken);
}
