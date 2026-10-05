namespace Servio.Services.Auth;

public interface ISessionValidator
{
    Task<bool> IsActiveAsync(string jti, CancellationToken cancellationToken = default);
    void MarkRevoked(string jti);
}
