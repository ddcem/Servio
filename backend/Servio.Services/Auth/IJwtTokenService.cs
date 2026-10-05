using Servio.Services.Database.Entities;

namespace Servio.Services.Auth;

public interface IJwtTokenService
{
    (string Token, string Jti, DateTime ExpiresAt) CreateToken(User user);
}
