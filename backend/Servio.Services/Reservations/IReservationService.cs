using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Reservations;

/// <summary>
/// Reservations are never deleted; they end as Completed, Cancelled or NoShow through the state machine.
/// </summary>
public interface IReservationService : IReadService<ReservationResponse, ReservationSearchObject>
{
    Task<ReservationResponse> InsertAsync(ReservationUpsertRequest request, CancellationToken cancellationToken = default);
    Task<ReservationResponse> UpdateAsync(int id, ReservationUpsertRequest request, CancellationToken cancellationToken = default);
    Task<ReservationResponse> ConfirmAsync(int id, CancellationToken cancellationToken = default);
    Task<ReservationResponse> CompleteAsync(int id, CancellationToken cancellationToken = default);
    Task<ReservationResponse> MarkNoShowAsync(int id, CancellationToken cancellationToken = default);
    Task<ReservationResponse> CancelAsync(int id, ReasonRequest request, CancellationToken cancellationToken = default);
}
