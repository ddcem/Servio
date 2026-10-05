using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using Servio.Model.Exceptions;

namespace Servio.Services.Auth;

public class CurrentUserService(IHttpContextAccessor httpContextAccessor) : ICurrentUserService
{
    private ClaimsPrincipal? Principal => httpContextAccessor.HttpContext?.User;

    public int UserId =>
        int.TryParse(Principal?.FindFirstValue(ClaimTypes.NameIdentifier), out var id)
            ? id
            : throw new AuthenticationException("You are not logged in.");

    public string? TokenJti => Principal?.FindFirstValue(JwtRegisteredClaimNames.Jti);

    public bool IsInRole(string role) => Principal?.IsInRole(role) ?? false;
}
