using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Servio.Model.Constants;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Recommendations;

namespace Servio.API.Controllers;

[ApiController]
[Route("api/recommendations")]
[Authorize(Roles = Roles.Waiter)]
public class RecommendationsController(IRecommendationService service) : ControllerBase
{
    /// <summary>POST because the cart is sent along; nothing is stored by this call.</summary>
    [HttpPost]
    public async Task<ActionResult<List<RecommendationResponse>>> Recommend(RecommendationRequest request,
        CancellationToken cancellationToken) =>
        Ok(await service.RecommendAsync(request, cancellationToken));
}
