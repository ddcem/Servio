using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Servio.Services.Database;

namespace Servio.Services.Auth;

/// <summary>
/// Checks on every authenticated request that the token's session was not revoked by logout.
/// Results are cached so the database is not hit on each request.
/// </summary>
public class SessionValidator(ServioDbContext context, IMemoryCache cache) : ISessionValidator
{
    private static readonly TimeSpan CacheDuration = TimeSpan.FromMinutes(5);

    public async Task<bool> IsActiveAsync(string jti, CancellationToken cancellationToken = default)
    {
        if (cache.TryGetValue(CacheKey(jti), out bool isActive))
        {
            return isActive;
        }

        isActive = await context.UserSessions
            .AnyAsync(x => x.TokenJti == jti
                           && x.RevokedAt == null
                           && x.ExpiresAt > DateTime.UtcNow
                           && x.User.IsActive, cancellationToken);

        cache.Set(CacheKey(jti), isActive, CacheDuration);
        return isActive;
    }

    public void MarkRevoked(string jti) => cache.Set(CacheKey(jti), false, CacheDuration);

    public async Task RevokeUserSessionsAsync(int userId, string? exceptJti = null, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var sessions = await context.UserSessions
            .Where(x => x.UserId == userId && x.RevokedAt == null && x.ExpiresAt > now && x.TokenJti != exceptJti)
            .ToListAsync(cancellationToken);

        foreach (var session in sessions)
        {
            session.RevokedAt = now;
            MarkRevoked(session.TokenJti);
        }
    }

    private static string CacheKey(string jti) => $"session:{jti}";
}
