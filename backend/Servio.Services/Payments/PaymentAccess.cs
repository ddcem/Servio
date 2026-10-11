using Servio.Model.Constants;
using Servio.Services.Auth;
using Servio.Services.Database.Entities;

namespace Servio.Services.Payments;

/// <summary>
/// A waiter sees the payments and receipts of the orders they served or the payments they took;
/// an admin sees all of them.
/// </summary>
public static class PaymentAccess
{
    public static IQueryable<Payment> VisibleTo(this IQueryable<Payment> query, ICurrentUserService currentUser)
    {
        if (!currentUser.IsInRole(Roles.Waiter))
        {
            return query;
        }

        var userId = currentUser.UserId;
        return query.Where(x => x.Order.WaiterId == userId || x.ProcessedByUserId == userId);
    }
}
