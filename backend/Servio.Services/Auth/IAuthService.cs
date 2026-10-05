using Servio.Model.Requests;
using Servio.Model.Responses;

namespace Servio.Services.Auth;

public interface IAuthService
{
    Task<LoginResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task LogoutAsync(CancellationToken cancellationToken = default);
    Task<UserResponse> GetCurrentUserAsync(CancellationToken cancellationToken = default);
}
