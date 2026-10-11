using Microsoft.EntityFrameworkCore;
using Servio.Model.Constants;
using Servio.Model.Exceptions;
using Servio.Services.Auth;
using Servio.Services.Database;
using Servio.Services.Database.Entities;

namespace Servio.Services.Tables;

/// <summary>
/// Waiters serve the tables assigned to them and unassigned ones; a table assigned to a colleague
/// is blocked until the admin reassigns it. The admin is not restricted.
/// </summary>
public static class TableAccess
{
    public static async Task EnsureCanServeAsync(ServioDbContext context, ICurrentUserService currentUser, RestaurantTable table,
        CancellationToken cancellationToken)
    {
        if (!currentUser.IsInRole(Roles.Waiter) || table.AssignedWaiterId is null || table.AssignedWaiterId == currentUser.UserId)
        {
            return;
        }

        var waiter = await context.Users
            .Where(x => x.Id == table.AssignedWaiterId)
            .Select(x => x.FirstName + " " + x.LastName)
            .FirstOrDefaultAsync(cancellationToken);
        throw new ForbiddenException(
            "Table {0} is served by {1}. Ask the admin to reassign it if you need to take it over.", table.Number, waiter ?? "?");
    }
}
