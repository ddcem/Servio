using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Orders;

public interface IOrderService : IReadService<OrderResponse, OrderSearchObject>
{
    /// <summary>Opens the table's bill and sends the first round to the kitchen and bar.</summary>
    Task<OrderResponse> CreateAsync(OrderCreateRequest request, CancellationToken cancellationToken = default);

    /// <summary>Sends another round of items for an open order.</summary>
    Task<OrderResponse> AddItemsAsync(int id, OrderAddItemsRequest request, CancellationToken cancellationToken = default);

    Task<OrderResponse> CancelAsync(int id, ReasonRequest request, CancellationToken cancellationToken = default);
}
