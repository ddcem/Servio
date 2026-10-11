using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Tables;

public interface IRestaurantTableService
    : ICrudService<RestaurantTableResponse, RestaurantTableSearchObject, RestaurantTableUpsertRequest, RestaurantTableUpsertRequest>
{
    /// <summary>
    /// Gives tables to waiters for the current shift. Open orders on a reassigned table move to the new
    /// waiter, and each waiter is notified about the tables they received.
    /// </summary>
    Task AssignAsync(TableAssignmentsRequest request, CancellationToken cancellationToken = default);
}
