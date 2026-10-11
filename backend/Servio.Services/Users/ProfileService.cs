using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Auth;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Images;
using Servio.Services.Localization;
using Servio.Services.Mapping;

namespace Servio.Services.Users;

public class ProfileService(
    ServioDbContext context,
    IPasswordHasher<User> passwordHasher,
    ISessionValidator sessionValidator,
    ICurrentUserService currentUser) : IProfileService
{
    public async Task<UserResponse> GetAsync(CancellationToken cancellationToken = default)
    {
        var user = await LoadCurrentUserAsync(cancellationToken);
        return user.ToResponse();
    }

    public async Task<UserResponse> UpdateAsync(ProfileUpdateRequest request, CancellationToken cancellationToken = default)
    {
        var user = await LoadCurrentUserAsync(cancellationToken);
        var email = request.Email.Trim();

        var normalizedEmail = email.ToLower();
        if (await context.Users.AnyAsync(x => x.Id != user.Id && x.Email.ToLower() == normalizedEmail, cancellationToken))
        {
            throw new BusinessException("The email {0} is already used by another employee.", email);
        }

        user.FirstName = request.FirstName.Trim();
        user.LastName = request.LastName.Trim();
        user.Email = email;
        user.PhoneNumber = string.IsNullOrWhiteSpace(request.PhoneNumber) ? null : request.PhoneNumber.Trim();

        await context.SaveChangesAsync(cancellationToken);
        return user.ToResponse();
    }

    public async Task<UserResponse> SetLanguageAsync(LanguageUpdateRequest request, CancellationToken cancellationToken = default)
    {
        var user = await LoadCurrentUserAsync(cancellationToken);
        user.PreferredLanguage = Languages.Normalize(request.Language);
        await context.SaveChangesAsync(cancellationToken);
        return user.ToResponse();
    }

    public async Task ChangePasswordAsync(ChangePasswordRequest request, CancellationToken cancellationToken = default)
    {
        var user = await LoadCurrentUserAsync(cancellationToken);

        if (passwordHasher.VerifyHashedPassword(user, user.PasswordHash, request.CurrentPassword) == PasswordVerificationResult.Failed)
        {
            throw new BusinessException("The current password is not correct.");
        }

        user.PasswordHash = passwordHasher.HashPassword(user, request.NewPassword);

        // Other devices are logged out; the device that changed the password stays logged in.
        await sessionValidator.RevokeUserSessionsAsync(user.Id, currentUser.TokenJti, cancellationToken);
        await context.SaveChangesAsync(cancellationToken);
    }

    public async Task<ImageFile> GetImageAsync(CancellationToken cancellationToken = default)
    {
        var userId = currentUser.UserId;
        var image = await context.Users
            .Where(x => x.Id == userId && x.ProfileImage != null)
            .Select(x => new { x.ProfileImage, x.ProfileImageContentType })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new NotFoundException("You have not added a profile image yet.");

        return new ImageFile(image.ProfileImage!, image.ProfileImageContentType!);
    }

    public async Task SetImageAsync(byte[] content, CancellationToken cancellationToken = default)
    {
        var image = ImageValidator.Validate(content);
        var user = await LoadCurrentUserAsync(cancellationToken);

        user.ProfileImage = image.Content;
        user.ProfileImageContentType = image.ContentType;
        await context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteImageAsync(CancellationToken cancellationToken = default)
    {
        var user = await LoadCurrentUserAsync(cancellationToken);

        user.ProfileImage = null;
        user.ProfileImageContentType = null;
        await context.SaveChangesAsync(cancellationToken);
    }

    private async Task<User> LoadCurrentUserAsync(CancellationToken cancellationToken)
    {
        var userId = currentUser.UserId;
        return await context.Users.Include(x => x.Role).FirstOrDefaultAsync(x => x.Id == userId, cancellationToken)
               ?? throw new NotFoundException("Your account was not found.");
    }
}
