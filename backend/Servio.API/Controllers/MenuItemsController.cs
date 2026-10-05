using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.API.Extensions;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Images;
using Servio.Services.Menu;

namespace Servio.API.Controllers;

[Route("api/menu-items")]
public class MenuItemsController(IMenuItemService service)
    : BaseCrudController<MenuItemResponse, MenuItemSearchObject, MenuItemUpsertRequest, MenuItemUpsertRequest>(service)
{
    private const int UploadLimitBytes = ImageValidator.MaxSizeBytes + 64 * 1024;

    [HttpPut("{id:int}/availability")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<MenuItemResponse>> SetAvailability(int id, MenuItemAvailabilityRequest request,
        CancellationToken cancellationToken) =>
        Ok(await service.SetAvailabilityAsync(id, request, cancellationToken));

    [HttpGet("{id:int}/image")]
    public async Task<IActionResult> GetImage(int id, CancellationToken cancellationToken)
    {
        var image = await service.GetImageAsync(id, cancellationToken);
        return File(image.Content, image.ContentType);
    }

    [HttpPut("{id:int}/image")]
    [Authorize(Roles = Roles.Admin)]
    [RequestSizeLimit(UploadLimitBytes)]
    public async Task<IActionResult> SetImage(int id, IFormFile file, CancellationToken cancellationToken)
    {
        await service.SetImageAsync(id, await file.ReadAllBytesAsync(cancellationToken), cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id:int}/image")]
    [Authorize(Roles = Roles.Admin)]
    public async Task<IActionResult> DeleteImage(int id, CancellationToken cancellationToken)
    {
        await service.DeleteImageAsync(id, cancellationToken);
        return NoContent();
    }

    [HttpPut("{id:int}/favorite")]
    public async Task<IActionResult> AddFavorite(int id, CancellationToken cancellationToken)
    {
        await service.AddFavoriteAsync(id, cancellationToken);
        return NoContent();
    }

    [HttpDelete("{id:int}/favorite")]
    public async Task<IActionResult> RemoveFavorite(int id, CancellationToken cancellationToken)
    {
        await service.RemoveFavoriteAsync(id, cancellationToken);
        return NoContent();
    }
}
