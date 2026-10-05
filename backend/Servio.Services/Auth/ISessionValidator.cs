namespace Servio.Services.Auth;

public interface ISessionValidator
{
    Task<bool> IsActiveAsync(string jti, CancellationToken cancellationToken = default);
    void MarkRevoked(string jti);

    /// <summary>
    /// Revokes the user's active sessions (all except <paramref name="exceptJti"/>). Changes are saved by the caller.
    /// </summary>
    Task RevokeUserSessionsAsync(int userId, string? exceptJti = null, CancellationToken cancellationToken = default);
}
