using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Extensions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Images;
using Servio.Services.Users;

namespace Servio.API.Controllers;

/// <summary>
/// The logged-in user's own profile; the user is always taken from the token.
/// </summary>
[ApiController]
[Route("api/profile")]
[Authorize]
public class ProfileController(IProfileService service) : ControllerBase
{
    private const int UploadLimitBytes = ImageValidator.MaxSizeBytes + 64 * 1024;

    [HttpGet]
    public async Task<ActionResult<UserResponse>> Get(CancellationToken cancellationToken) =>
        Ok(await service.GetAsync(cancellationToken));

    [HttpPut]
    public async Task<ActionResult<UserResponse>> Update(ProfileUpdateRequest request, CancellationToken cancellationToken) =>
        Ok(await service.UpdateAsync(request, cancellationToken));

    [HttpPut("password")]
    public async Task<IActionResult> ChangePassword(ChangePasswordRequest request, CancellationToken cancellationToken)
    {
        await service.ChangePasswordAsync(request, cancellationToken);
        return NoContent();
    }

    [HttpGet("image")]
    public async Task<IActionResult> GetImage(CancellationToken cancellationToken)
    {
        var image = await service.GetImageAsync(cancellationToken);
        return File(image.Content, image.ContentType);
    }

    [HttpPut("image")]
    [RequestSizeLimit(UploadLimitBytes)]
    public async Task<IActionResult> SetImage(IFormFile file, CancellationToken cancellationToken)
    {
        await service.SetImageAsync(await file.ReadAllBytesAsync(cancellationToken), cancellationToken);
        return NoContent();
    }

    [HttpDelete("image")]
    public async Task<IActionResult> DeleteImage(CancellationToken cancellationToken)
    {
        await service.DeleteImageAsync(cancellationToken);
        return NoContent();
    }
}
