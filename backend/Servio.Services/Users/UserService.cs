using System.Linq.Expressions;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Servio.Model.Constants;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Auth;
using Servio.Services.Base;
using Servio.Services.Database;
using Servio.Services.Database.Entities;
using Servio.Services.Images;

namespace Servio.Services.Users;

/// <summary>
/// Employee management for the admin. Employees with work history are deactivated instead of deleted.
/// </summary>
public class UserService(
    ServioDbContext context,
    IPasswordHasher<User> passwordHasher,
    ISessionValidator sessionValidator,
    ICurrentUserService currentUser)
    : BaseCrudService<User, UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>(context), IUserService
{
    protected override string EntityName => "Employee";

    protected override Expression<Func<User, UserResponse>> Projection => x => new UserResponse
    {
        Id = x.Id,
        FirstName = x.FirstName,
        LastName = x.LastName,
        Username = x.Username,
        Email = x.Email,
        PhoneNumber = x.PhoneNumber,
        RoleId = x.RoleId,
        Role = x.Role.Name,
        IsActive = x.IsActive,
        HasProfileImage = x.ProfileImage != null,
        PreferredLanguage = x.PreferredLanguage,
        CreatedAt = x.CreatedAt,
        LastLoginAt = x.LastLoginAt,
        HasActivity = Context.Orders.Any(o => o.WaiterId == x.Id)
                      || Context.Reservations.Any(r => r.CreatedByUserId == x.Id)
                      || Context.OrderTicketStatusHistory.Any(h => h.ChangedByUserId == x.Id)
                      || Context.ReservationStatusHistory.Any(h => h.ChangedByUserId == x.Id)
                      || Context.Payments.Any(p => p.ProcessedByUserId == x.Id)
                      || Context.Refunds.Any(r => r.RefundedByUserId == x.Id)
                      || Context.RestaurantSettings.Any(s => s.UpdatedByUserId == x.Id)
    };

    protected override IQueryable<User> ApplyFilter(IQueryable<User> query, UserSearchObject search)
    {
        if (Normalize(search.FTS) is { } fts)
        {
            var pattern = ContainsPattern(fts);
            query = query.Where(x => EF.Functions.ILike(x.FirstName + " " + x.LastName, pattern)
                                     || EF.Functions.ILike(x.Username, pattern)
                                     || EF.Functions.ILike(x.Email, pattern));
        }

        if (search.RoleId is { } roleId)
        {
            query = query.Where(x => x.RoleId == roleId);
        }

        if (search.IsActive is { } isActive)
        {
            query = query.Where(x => x.IsActive == isActive);
        }

        return query;
    }

    protected override IQueryable<User> ApplyOrdering(IQueryable<User> query, UserSearchObject search) =>
        query.OrderByDescending(x => x.CreatedAt).ThenByDescending(x => x.Id);

    protected override void MapInsert(UserInsertRequest request, User entity)
    {
        entity.FirstName = request.FirstName.Trim();
        entity.LastName = request.LastName.Trim();
        entity.Username = request.Username.Trim();
        entity.Email = request.Email.Trim();
        entity.PhoneNumber = Normalize(request.PhoneNumber);
        entity.RoleId = request.RoleId!.Value;
        entity.IsActive = request.IsActive;
        entity.CreatedAt = DateTime.UtcNow;
        entity.PasswordHash = passwordHasher.HashPassword(entity, request.Password);
    }

    protected override void MapUpdate(UserUpdateRequest request, User entity)
    {
        entity.FirstName = request.FirstName.Trim();
        entity.LastName = request.LastName.Trim();
        entity.Username = request.Username.Trim();
        entity.Email = request.Email.Trim();
        entity.PhoneNumber = Normalize(request.PhoneNumber);
        entity.RoleId = request.RoleId!.Value;
        entity.IsActive = request.IsActive;

        if (!string.IsNullOrEmpty(request.NewPassword))
        {
            entity.PasswordHash = passwordHasher.HashPassword(entity, request.NewPassword);
        }
    }

    protected override Task BeforeInsertAsync(UserInsertRequest request, User entity, CancellationToken cancellationToken) =>
        ValidateAsync(entity, cancellationToken);

    protected override async Task BeforeUpdateAsync(UserUpdateRequest request, User entity, CancellationToken cancellationToken)
    {
        await ValidateAsync(entity, cancellationToken);

        var entry = Context.Entry(entity);
        var roleChanged = entry.Property(x => x.RoleId).IsModified;
        var deactivated = entry.Property(x => x.IsActive).IsModified && !entity.IsActive;

        if (entity.Id == currentUser.UserId && (roleChanged || deactivated))
        {
            throw new BusinessException("You cannot change your own role or deactivate your own account.");
        }

        if (roleChanged || deactivated)
        {
            await EnsureAnotherActiveAdminAsync(entity, (int)entry.Property(x => x.RoleId).OriginalValue, cancellationToken);
        }

        // Someone who no longer works as a waiter leaves their tables free for the others.
        if (roleChanged || deactivated)
        {
            await Context.RestaurantTables
                .Where(x => x.AssignedWaiterId == entity.Id)
                .ForEachAsync(x => x.AssignedWaiterId = null, cancellationToken);
        }

        // Deactivation, a new role or a new password take effect immediately: existing logins stop working.
        if (roleChanged || deactivated || entry.Property(x => x.PasswordHash).IsModified)
        {
            await sessionValidator.RevokeUserSessionsAsync(entity.Id, cancellationToken: cancellationToken);
        }
    }

    protected override async Task BeforeDeleteAsync(User entity, CancellationToken cancellationToken)
    {
        if (entity.Id == currentUser.UserId)
        {
            throw new BusinessException("You cannot delete your own account.");
        }

        var hasActivity = await Query.Where(x => x.Id == entity.Id).Select(Projection).Select(x => x.HasActivity)
            .FirstAsync(cancellationToken);
        if (hasActivity)
        {
            throw new BusinessException(
                "{0} {1} has orders, reservations or payments in the system and cannot be deleted. Deactivate the account instead.", entity.FirstName, entity.LastName);
        }

        await EnsureAnotherActiveAdminAsync(entity, entity.RoleId, cancellationToken);
    }

    public async Task<ImageFile> GetImageAsync(int id, CancellationToken cancellationToken = default)
    {
        var image = await Context.Users
            .Where(x => x.Id == id && x.ProfileImage != null)
            .Select(x => new { x.ProfileImage, x.ProfileImageContentType })
            .FirstOrDefaultAsync(cancellationToken)
            ?? throw new NotFoundException("This employee has no profile image.");

        return new ImageFile(image.ProfileImage!, image.ProfileImageContentType!);
    }

    private async Task ValidateAsync(User entity, CancellationToken cancellationToken)
    {
        if (!await Context.Roles.AnyAsync(x => x.Id == entity.RoleId, cancellationToken))
        {
            throw new BusinessException("The selected role does not exist.");
        }

        var username = entity.Username.ToLower();
        if (await Context.Users.AnyAsync(x => x.Id != entity.Id && x.Username.ToLower() == username, cancellationToken))
        {
            throw new BusinessException("The username '{0}' is already taken.", entity.Username);
        }

        var email = entity.Email.ToLower();
        if (await Context.Users.AnyAsync(x => x.Id != entity.Id && x.Email.ToLower() == email, cancellationToken))
        {
            throw new BusinessException("The email {0} is already used by another employee.", entity.Email);
        }
    }

    /// <summary>The system must always keep at least one active administrator.</summary>
    private async Task EnsureAnotherActiveAdminAsync(User entity, int originalRoleId, CancellationToken cancellationToken)
    {
        var adminRoleId = await Context.Roles.Where(x => x.Name == Roles.Admin).Select(x => x.Id).FirstAsync(cancellationToken);
        if (originalRoleId != adminRoleId)
        {
            return;
        }

        var otherActiveAdmins = await Context.Users
            .CountAsync(x => x.Id != entity.Id && x.IsActive && x.RoleId == adminRoleId, cancellationToken);
        if (otherActiveAdmins == 0)
        {
            throw new BusinessException("This is the last active administrator. Add another administrator first.");
        }
    }
}
