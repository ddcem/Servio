namespace Servio.Services.Recommendations;

/// <summary>
/// How much each signal counts. With little history the content similarity dominates (cold start);
/// as orders accumulate, the weight shifts towards what guests actually order together.
/// </summary>
public static class RecommenderWeights
{
    /// <summary>Orders containing the source item after which history and content weigh about the same.</summary>
    public const double HistoryHalfPoint = 20;

    /// <summary>Times a pair must have been suggested before its acceptance rate is mentioned in the reason.</summary>
    public const int MinShownForAcceptanceReason = 5;

    /// <summary>Only recent orders describe current habits.</summary>
    public static readonly TimeSpan HistoryWindow = TimeSpan.FromDays(180);

    public static (double Content, double History, double Acceptance) For(int ordersWithSource)
    {
        var historyConfidence = ordersWithSource / (ordersWithSource + HistoryHalfPoint);
        return (
            Content: 0.6 - 0.3 * historyConfidence,
            History: 0.1 + 0.4 * historyConfidence,
            Acceptance: 0.3 - 0.1 * historyConfidence);
    }
}
