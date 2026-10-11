using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Auth;

namespace Servio.API.Controllers;

[ApiController]
[Route("api/auth")]
[Authorize]
public class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<ActionResult<LoginResponse>> Login(LoginRequest request, CancellationToken cancellationToken) =>
        Ok(await authService.LoginAsync(request, cancellationToken));

    [HttpPost("logout")]
    public async Task<IActionResult> Logout(CancellationToken cancellationToken)
    {
        await authService.LogoutAsync(cancellationToken);
        return NoContent();
    }

    [HttpPost("forgot-password")]
    [AllowAnonymous]
    public async Task<ActionResult<MessageResponse>> ForgotPassword(ForgotPasswordRequest request, CancellationToken cancellationToken) =>
        Ok(await authService.ForgotPasswordAsync(request, cancellationToken));

    [HttpPost("reset-password")]
    [AllowAnonymous]
    public async Task<ActionResult<MessageResponse>> ResetPassword(ResetPasswordRequest request, CancellationToken cancellationToken) =>
        Ok(await authService.ResetPasswordAsync(request, cancellationToken));
}
