using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Orders;

public interface IOrderTicketService : IReadService<OrderTicketResponse, OrderTicketSearchObject>
{
    /// <summary>Kitchen/bar: New → Preparing.</summary>
    Task<OrderTicketResponse> StartAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>Kitchen/bar: Preparing → Ready; notifies the waiter.</summary>
    Task<OrderTicketResponse> MarkReadyAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>Waiter: Ready → Served.</summary>
    Task<OrderTicketResponse> ServeAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>Waiter: cancels a ticket that the station has not started yet.</summary>
    Task<OrderTicketResponse> CancelAsync(int id, ReasonRequest request, CancellationToken cancellationToken = default);

    Task<List<StationSummaryResponse>> GetStationSummariesAsync(CancellationToken cancellationToken = default);
}
