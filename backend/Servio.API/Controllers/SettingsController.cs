using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Settings;

namespace Servio.API.Controllers;

[ApiController]
[Route("api/settings")]
[Authorize]
public class SettingsController(ISettingsService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<SettingsResponse>> Get(CancellationToken cancellationToken) =>
        Ok(await service.GetAsync(cancellationToken));

    [HttpPut]
    [Authorize(Roles = Roles.Admin)]
    public async Task<ActionResult<SettingsResponse>> Update(SettingsUpdateRequest request, CancellationToken cancellationToken) =>
        Ok(await service.UpdateAsync(request, cancellationToken));
}
