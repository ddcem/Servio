using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Images;

namespace Servio.Services.Users;

/// <summary>
/// The logged-in user's own account. The user id always comes from the token.
/// </summary>
public interface IProfileService
{
    Task<UserResponse> GetAsync(CancellationToken cancellationToken = default);
    Task<UserResponse> UpdateAsync(ProfileUpdateRequest request, CancellationToken cancellationToken = default);
    /// <summary>Saves the app language the user chose; notifications and emails use it as well.</summary>
    Task<UserResponse> SetLanguageAsync(LanguageUpdateRequest request, CancellationToken cancellationToken = default);
    Task ChangePasswordAsync(ChangePasswordRequest request, CancellationToken cancellationToken = default);
    Task<ImageFile> GetImageAsync(CancellationToken cancellationToken = default);
    Task SetImageAsync(byte[] content, CancellationToken cancellationToken = default);
    Task DeleteImageAsync(CancellationToken cancellationToken = default);
}
