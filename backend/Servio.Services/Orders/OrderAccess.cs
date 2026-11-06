using Servio.Model.Constants;
using Servio.Model.Enums;
using Servio.Services.Auth;
using Servio.Services.Database.Entities;

namespace Servio.Services.Orders;

/// <summary>
/// Which orders a user may read, decided on the server from the token. A waiter sees the orders they opened
/// and the open orders of tables they may serve (assigned to them or unassigned, as in <see cref="Tables.TableAccess"/>);
/// the admin sees all of them.
/// </summary>
public static class OrderAccess
{
    public static IQueryable<Order> VisibleTo(this IQueryable<Order> query, ICurrentUserService currentUser)
    {
        if (!currentUser.IsInRole(Roles.Waiter))
        {
            return query;
        }

        var userId = currentUser.UserId;
        return query.Where(x => x.WaiterId == userId
                                || (x.Status == OrderStatus.Open
                                    && (x.Table.AssignedWaiterId == null || x.Table.AssignedWaiterId == userId)));
    }
}
