using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Users;

namespace Servio.API.Controllers;

/// <summary>
/// Employee management; admin only, including reading.
/// </summary>
[Route("api/users")]
[Authorize(Roles = Roles.Admin)]
public class UsersController(IUserService service)
    : BaseCrudController<UserResponse, UserSearchObject, UserInsertRequest, UserUpdateRequest>(service)
{
    [HttpGet("{id:int}/image")]
    public async Task<IActionResult> GetImage(int id, CancellationToken cancellationToken)
    {
        var image = await service.GetImageAsync(id, cancellationToken);
        return File(image.Content, image.ContentType);
    }
}
