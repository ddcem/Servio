using Servio.Model.Responses;
using Servio.Services.Database.Entities;

namespace Servio.Services.Mapping;

public static class UserMappings
{
    public static UserResponse ToResponse(this User user) => new()
    {
        Id = user.Id,
        FirstName = user.FirstName,
        LastName = user.LastName,
        Username = user.Username,
        Email = user.Email,
        PhoneNumber = user.PhoneNumber,
        Role = user.Role.Name,
        IsActive = user.IsActive,
        HasProfileImage = user.ProfileImage != null
    };
}
