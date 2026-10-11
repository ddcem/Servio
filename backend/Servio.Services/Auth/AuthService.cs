using System.Security.Cryptography;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Localization;
using Servio.Services.Mapping;
using Servio.Services.Messaging;

namespace Servio.Services.Auth;

public class AuthService(
    ServioDbContext context,
    IPasswordHasher<User> passwordHasher,
    IJwtTokenService tokenService,
    ISessionValidator sessionValidator,
    ICurrentUserService currentUser,
    IMessagePublisher messagePublisher,
    ILogger<AuthService> logger) : IAuthService
{
    private const string InvalidCredentialsMessage = "Incorrect username or password.";
    private const string ResetCodeSentMessage = "If an account with that email exists, a 6-digit reset code was sent to it. The code is valid for 15 minutes.";
    private const string InvalidResetCodeMessage = "The reset code is not valid or has expired. Request a new code.";

    private static readonly TimeSpan ResetCodeLifetime = TimeSpan.FromMinutes(15);
    private static readonly TimeSpan ResetCodeResendInterval = TimeSpan.FromMinutes(1);
    private const int MaxResetCodeAttempts = 5;

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

    public async Task<MessageResponse> ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLower();
        var user = await context.Users.FirstOrDefaultAsync(x => x.Email.ToLower() == email && x.IsActive, cancellationToken);
        if (user is null)
        {
            logger.LogInformation("Password reset requested for unknown or inactive email {Email}", request.Email);
            return new MessageResponse(Translator.T(ResetCodeSentMessage));
        }

        var now = DateTime.UtcNow;
        var activeTokens = await context.PasswordResetTokens
            .Where(x => x.UserId == user.Id && x.UsedAt == null && x.ExpiresAt > now)
            .ToListAsync(cancellationToken);

        if (activeTokens.Any(x => x.CreatedAt > now - ResetCodeResendInterval))
        {
            throw new BusinessException("A code was sent less than a minute ago. Check your inbox or try again in a minute.");
        }

        // Only the newest code is valid.
        foreach (var token in activeTokens)
        {
            token.UsedAt = now;
        }

        var code = RandomNumberGenerator.GetInt32(0, 1_000_000).ToString("D6");
        context.PasswordResetTokens.Add(new PasswordResetToken
        {
            UserId = user.Id,
            CodeHash = passwordHasher.HashPassword(user, code),
            CreatedAt = now,
            ExpiresAt = now + ResetCodeLifetime
        });

        await context.SaveChangesAsync(cancellationToken);

        await messagePublisher.PublishEmailAsync(
            EmailTemplates.PasswordReset(user.Email, user.FirstName, code, (int)ResetCodeLifetime.TotalMinutes, user.PreferredLanguage),
            cancellationToken);

        return new MessageResponse(Translator.T(ResetCodeSentMessage));
    }

    public async Task<MessageResponse> ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken = default)
    {
        var email = request.Email.Trim().ToLower();
        var now = DateTime.UtcNow;

        var user = await context.Users.FirstOrDefaultAsync(x => x.Email.ToLower() == email && x.IsActive, cancellationToken)
                   ?? throw new BusinessException(InvalidResetCodeMessage);

        var token = await context.PasswordResetTokens
            .Where(x => x.UserId == user.Id && x.UsedAt == null && x.ExpiresAt > now)
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new BusinessException(InvalidResetCodeMessage);

        if (passwordHasher.VerifyHashedPassword(user, token.CodeHash, request.Code) == PasswordVerificationResult.Failed)
        {
            // A few wrong guesses burn the code, so it cannot be brute-forced within its lifetime.
            token.FailedAttempts++;
            if (token.FailedAttempts >= MaxResetCodeAttempts)
            {
                token.UsedAt = now;
            }

            await context.SaveChangesAsync(cancellationToken);
            logger.LogInformation("Wrong password reset code for user {UserId} (attempt {Attempt})", user.Id, token.FailedAttempts);
            throw new BusinessException(InvalidResetCodeMessage);
        }

        token.UsedAt = now;
        user.PasswordHash = passwordHasher.HashPassword(user, request.NewPassword);
        await sessionValidator.RevokeUserSessionsAsync(user.Id, cancellationToken: cancellationToken);

        await context.SaveChangesAsync(cancellationToken);
        return new MessageResponse(Translator.T("Your password was changed. You can now log in with the new password."));
    }
}
