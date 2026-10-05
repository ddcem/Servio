using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Mapping;

namespace Servio.Services.Auth;

public class AuthService(
    ServioDbContext context,
    IPasswordHasher<User> passwordHasher,
    IJwtTokenService tokenService,
    ISessionValidator sessionValidator,
    ICurrentUserService currentUser,
    ILogger<AuthService> logger) : IAuthService
{
    private const string InvalidCredentialsMessage = "Incorrect username or password.";

    public async Task<LoginResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        var user = await context.Users
            .Include(x => x.Role)
            .FirstOrDefaultAsync(x => x.Username == request.Username, cancellationToken);

        if (user is null)
        {
            throw new AuthenticationException(InvalidCredentialsMessage);
        }

        var verification = passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.Password);
        if (verification == PasswordVerificationResult.Failed)
        {
            logger.LogInformation("Failed login attempt for user {Username}", request.Username);
            throw new AuthenticationException(InvalidCredentialsMessage);
        }

        if (!user.IsActive)
        {
            throw new AuthenticationException("Your account is deactivated. Please contact the administrator.");
        }

        var (token, jti, expiresAt) = tokenService.CreateToken(user);

        context.UserSessions.Add(new UserSession
        {
            UserId = user.Id,
            TokenJti = jti,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = expiresAt
        });
        user.LastLoginAt = DateTime.UtcNow;

        await context.SaveChangesAsync(cancellationToken);

        return new LoginResponse(token, expiresAt, user.ToResponse());
    }

    public async Task LogoutAsync(CancellationToken cancellationToken = default)
    {
        var jti = currentUser.TokenJti ?? throw new AuthenticationException("You are not logged in.");

        var session = await context.UserSessions
            .FirstOrDefaultAsync(x => x.TokenJti == jti && x.RevokedAt == null, cancellationToken);

        if (session is not null)
        {
            session.RevokedAt = DateTime.UtcNow;
            await context.SaveChangesAsync(cancellationToken);
        }

        sessionValidator.MarkRevoked(jti);
    }

    public async Task<UserResponse> GetCurrentUserAsync(CancellationToken cancellationToken = default)
    {
        var user = await context.Users
            .AsNoTracking()
            .Include(x => x.Role)
            .FirstOrDefaultAsync(x => x.Id == currentUser.UserId, cancellationToken)
            ?? throw new NotFoundException("User was not found.");

        return user.ToResponse();
    }
}
