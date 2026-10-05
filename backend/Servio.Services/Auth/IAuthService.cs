using Servio.Model.Requests;
using Servio.Model.Responses;

namespace Servio.Services.Auth;

public interface IAuthService
{
    Task<LoginResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task LogoutAsync(CancellationToken cancellationToken = default);
    Task<UserResponse> GetCurrentUserAsync(CancellationToken cancellationToken = default);

    /// <summary>Emails a one-time reset code. The response is the same whether or not the email exists.</summary>
    Task<MessageResponse> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken = default);

    Task<MessageResponse> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken = default);
}
