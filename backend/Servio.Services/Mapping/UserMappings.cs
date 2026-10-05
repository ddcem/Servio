using Servio.Model.Responses;
using Servio.Services.Database.Entities;

namespace Servio.Services.Mapping;

public static class UserMappings
{
    /// <summary>Maps a user loaded with its Role. HasActivity is only computed by the user list.</summary>
    public static UserResponse ToResponse(this User user) => new()
    {
        Id = user.Id,
        FirstName = user.FirstName,
        LastName = user.LastName,
        Username = user.Username,
        Email = user.Email,
        PhoneNumber = user.PhoneNumber,
        RoleId = user.RoleId,
        Role = user.Role.Name,
        IsActive = user.IsActive,
        HasProfileImage = user.ProfileImage != null,
        CreatedAt = user.CreatedAt,
        LastLoginAt = user.LastLoginAt
    };
}
