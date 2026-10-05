using Servio.Model.Requests;
using Servio.Model.Responses;

namespace Servio.Services.Recommendations;

public interface IRecommendationService
{
    Task<List<RecommendationResponse>> RecommendAsync(RecommendationRequest request, CancellationToken cancellationToken = default);

    /// <summary>Drops cached menu features after the menu changed.</summary>
    void InvalidateMenu();
}
