using Servio.Model.Requests;
using Servio.Model.Responses;

namespace Servio.Services.Settings;

public interface ISettingsService
{
    Task<SettingsResponse> GetAsync(CancellationToken cancellationToken = default);
    Task<SettingsResponse> UpdateAsync(SettingsUpdateRequest request, CancellationToken cancellationToken = default);
}
