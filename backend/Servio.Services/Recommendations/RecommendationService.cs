using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Servio.Model.Enums;
using Servio.Model.Exceptions;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Services.Database;

namespace Servio.Services.Recommendations;

/// <summary>
/// Upselling suggestions for the item the waiter just added. Every candidate is scored with three signals:
/// content similarity (cosine over item attributes), how often it was ordered together with the source item,
/// and how often waiters' guests accepted it when it was suggested. See recommender-dokumentacija.md.
/// </summary>
public class RecommendationService(ServioDbContext context, IMemoryCache cache) : IRecommendationService
{
    private const string FeaturesCacheKey = "recommender:features";
    private static readonly TimeSpan FeaturesCacheDuration = TimeSpan.FromMinutes(10);
    private static readonly TimeSpan HistoryCacheDuration = TimeSpan.FromMinutes(10);

    public async Task<List<RecommendationResponse>> RecommendAsync(RecommendationRequest request,
        CancellationToken cancellationToken = default)
    {
        var features = await GetFeaturesAsync(cancellationToken);
        var sourceId = request.SourceMenuItemId!.Value;
        var source = features.GetValueOrDefault(sourceId) ?? throw new NotFoundException("Menu item was not found.");

        var cart = request.CartMenuItemIds.Append(sourceId).ToHashSet();
        var coursesInCart = cart.Where(features.ContainsKey).Select(id => features[id].CourseType).ToHashSet();

        var candidates = features.Values.Where(x => x.IsAvailableToday && !cart.Contains(x.Id)).ToList();

        // Upselling completes the meal: prefer courses the table has not ordered yet
        // (steak → drink; once a drink is there → side or dessert).
        var complementary = candidates.Where(x => !coursesInCart.Contains(x.CourseType)).ToList();
        if (complementary.Count > 0)
        {
            candidates = complementary;
        }

        if (candidates.Count == 0)
        {
            return [];
        }

        var history = await GetHistoryAsync(sourceId, cancellationToken);
        var acceptance = await context.RecommendationEvents
            .Where(x => x.SourceMenuItemId == sourceId)
            .GroupBy(x => x.RecommendedMenuItemId)
            .Select(g => new { MenuItemId = g.Key, Shown = g.Count(), Accepted = g.Count(x => x.WasAccepted) })
            .ToDictionaryAsync(x => x.MenuItemId, x => (x.Shown, x.Accepted), cancellationToken);

        var weights = RecommenderWeights.For(history.OrdersWithSource);
        var maxConfidence = history.Confidence.Count == 0 ? 0 : history.Confidence.Values.Max();

        var scored = candidates.Select(candidate =>
        {
            var content = CosineSimilarity(source.Vector, candidate.Vector);
            var confidence = history.Confidence.GetValueOrDefault(candidate.Id);
            var historyScore = maxConfidence > 0 ? confidence / maxConfidence : 0;

            // Laplace smoothing: an untested pair starts at 0.5 and moves with real feedback.
            var (shown, accepted) = acceptance.GetValueOrDefault(candidate.Id);
            var acceptanceRate = (accepted + 1.0) / (shown + 2.0);

            var score = weights.Content * content + weights.History * historyScore + weights.Acceptance * acceptanceRate;

            return new
            {
                Candidate = candidate,
                Score = score,
                Content = content,
                History = historyScore,
                Acceptance = acceptanceRate,
                Reason = BuildReason(source, candidate, weights.Content * content, weights.History * historyScore,
                    confidence, shown, acceptanceRate)
            };
        });

        // Best item per course first, so the suggestions cover different parts of the meal.
        return scored
            .GroupBy(x => x.Candidate.CourseType)
            .Select(g => g.OrderByDescending(x => x.Score).ThenBy(x => x.Candidate.Name).First())
            .OrderByDescending(x => x.Score)
            .Take(request.Take)
            .Select(x => new RecommendationResponse
            {
                MenuItemId = x.Candidate.Id,
                Name = x.Candidate.Name,
                Price = x.Candidate.Price,
                CategoryName = x.Candidate.CategoryName,
                CourseType = x.Candidate.CourseType,
                HasImage = x.Candidate.HasImage,
                Score = Math.Round((decimal)x.Score, 4),
                Reason = x.Reason,
                ContentScore = Math.Round(x.Content, 4),
                HistoryScore = Math.Round(x.History, 4),
                AcceptanceScore = Math.Round(x.Acceptance, 4)
            })
            .ToList();
    }

    public void InvalidateMenu() => cache.Remove(FeaturesCacheKey);

    private static string BuildReason(MenuItemFeatures source, MenuItemFeatures candidate, double contentPart,
        double historyPart, double confidence, int shown, double acceptanceRate)
    {
        string reason;
        if (historyPart >= contentPart && confidence > 0)
        {
            reason = $"Ordered with {source.Name} in {confidence * 100:0}% of orders";
        }
        else
        {
            var traits = new List<string>();
            if (candidate.PriceTier == source.PriceTier)
            {
                traits.Add($"same {candidate.PriceTier.ToString().ToLower()} price range");
            }

            var sharedTags = candidate.Tags.Intersect(source.Tags).Take(2).ToList();
            if (sharedTags.Count > 0)
            {
                traits.Add($"both {string.Join(" and ", sharedTags).ToLower()}");
            }

            reason = traits.Count > 0
                ? $"Pairs with {source.Name}: {string.Join(", ", traits)}"
                : $"Completes the order with {CourseLabel(candidate.CourseType)}";
        }

        if (shown >= RecommenderWeights.MinShownForAcceptanceReason)
        {
            reason += $" · accepted {acceptanceRate * 100:0}% of the times it was suggested";
        }

        return reason.Length <= 200 ? reason : reason[..199] + "…";
    }

    private static string CourseLabel(CourseType courseType) => courseType switch
    {
        CourseType.Appetizer => "a starter",
        CourseType.MainCourse => "a main course",
        CourseType.Side => "a side",
        CourseType.Dessert => "a dessert",
        _ => "a drink"
    };

    private static double CosineSimilarity(double[] a, double[] b)
    {
        double dot = 0, normA = 0, normB = 0;
        for (var i = 0; i < a.Length; i++)
        {
            dot += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        return normA == 0 || normB == 0 ? 0 : dot / (Math.Sqrt(normA) * Math.Sqrt(normB));
    }

    /// <summary>
    /// Feature vectors for the whole menu. Price tiers are relative to the item's own course
    /// (a premium drink and a premium main course share a tier).
    /// </summary>
    private async Task<Dictionary<int, MenuItemFeatures>> GetFeaturesAsync(CancellationToken cancellationToken)
    {
        if (cache.TryGetValue(FeaturesCacheKey, out Dictionary<int, MenuItemFeatures>? cached) && cached is not null)
        {
            return cached;
        }

        var items = await context.MenuItems
            .AsNoTracking()
            .Where(x => !x.IsDeleted)
            .Select(x => new
            {
                x.Id,
                x.Name,
                x.Price,
                CategoryName = x.Category.Name,
                x.Category.CourseType,
                HasImage = x.Image != null,
                x.IsAvailableToday,
                TagIds = x.Tags.Select(t => t.Id).ToList(),
                TagNames = x.Tags.OrderBy(t => t.Name).Select(t => t.Name).ToList()
            })
            .ToListAsync(cancellationToken);

        var tagIndex = items.SelectMany(x => x.TagIds).Distinct().Order()
            .Select((tagId, index) => (tagId, index)).ToDictionary(x => x.tagId, x => x.index);
        var courseCount = Enum.GetValues<CourseType>().Length;
        var tierCount = Enum.GetValues<PriceTier>().Length;

        var tiers = items
            .GroupBy(x => x.CourseType)
            .SelectMany(g =>
            {
                var ordered = g.OrderBy(x => x.Price).ToList();
                return ordered.Select((item, rank) => (item.Id, Tier: (PriceTier)(rank * tierCount / ordered.Count)));
            })
            .ToDictionary(x => x.Id, x => x.Tier);

        var features = items.ToDictionary(x => x.Id, x =>
        {
            var vector = new double[courseCount + tierCount + tagIndex.Count];
            vector[(int)x.CourseType] = 1;
            vector[courseCount + (int)tiers[x.Id]] = 1;
            foreach (var tagId in x.TagIds)
            {
                vector[courseCount + tierCount + tagIndex[tagId]] = 1;
            }

            return new MenuItemFeatures
            {
                Id = x.Id,
                Name = x.Name,
                Price = x.Price,
                CategoryName = x.CategoryName,
                CourseType = x.CourseType,
                HasImage = x.HasImage,
                IsAvailableToday = x.IsAvailableToday,
                PriceTier = tiers[x.Id],
                Tags = x.TagNames,
                Vector = vector
            };
        });

        cache.Set(FeaturesCacheKey, features, FeaturesCacheDuration);
        return features;
    }

    private record HistoryStats(int OrdersWithSource, Dictionary<int, double> Confidence);

    /// <summary>
    /// Co-occurrence from paid orders: confidence(source → item) = orders with both / orders with source.
    /// </summary>
    private async Task<HistoryStats> GetHistoryAsync(int sourceId, CancellationToken cancellationToken)
    {
        var cacheKey = $"recommender:history:{sourceId}";
        if (cache.TryGetValue(cacheKey, out HistoryStats? cached) && cached is not null)
        {
            return cached;
        }

        var since = DateTime.UtcNow - RecommenderWeights.HistoryWindow;
        var ordersWithSource = context.OrderItems
            .Where(x => x.MenuItemId == sourceId && x.Order.Status == OrderStatus.Completed && x.Order.OpenedAt >= since)
            .Select(x => x.OrderId)
            .Distinct();

        var sourceCount = await ordersWithSource.CountAsync(cancellationToken);
        var together = await context.OrderItems
            .Where(x => x.MenuItemId != sourceId && ordersWithSource.Contains(x.OrderId))
            .GroupBy(x => x.MenuItemId)
            .Select(g => new { MenuItemId = g.Key, Orders = g.Select(x => x.OrderId).Distinct().Count() })
            .ToListAsync(cancellationToken);

        var stats = new HistoryStats(sourceCount,
            sourceCount == 0 ? [] : together.ToDictionary(x => x.MenuItemId, x => (double)x.Orders / sourceCount));

        cache.Set(cacheKey, stats, HistoryCacheDuration);
        return stats;
    }
}
