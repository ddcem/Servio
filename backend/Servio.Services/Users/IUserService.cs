using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;
using Servio.Services.Images;

namespace Servio.Services.Users;

public interface IUserService : ICrudService<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>
{
    Task<ImageFile> GetImageAsync(int id, CancellationToken cancellationToken = default);
}
