using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;
using Servio.Services.Images;

namespace Servio.Services.Menu;

public interface IMenuItemService
    : ICrudService<MenuItemResponse, MenuItemSearchObject, MenuItemUpsertRequest, MenuItemUpsertRequest>
{
    Task<MenuItemResponse> SetAvailabilityAsync(int id, MenuItemAvailabilityRequest request, CancellationToken cancellationToken = default);
    Task<ImageFile> GetImageAsync(int id, CancellationToken cancellationToken = default);
    Task SetImageAsync(int id, byte[] content, CancellationToken cancellationToken = default);
    Task DeleteImageAsync(int id, CancellationToken cancellationToken = default);
    Task AddFavoriteAsync(int id, CancellationToken cancellationToken = default);
    Task RemoveFavoriteAsync(int id, CancellationToken cancellationToken = default);
}
