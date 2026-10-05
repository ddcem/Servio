namespace Servio.Model.Constants;

public static class TipOptions
{
    /// <summary>Tip percentages offered at checkout; 0 means no tip.</summary>
    public static readonly int[] Percentages = [0, 10, 15, 20, 25];

    public const string InvalidTipMessage = "Choose a tip of 0, 10, 15, 20 or 25 percent.";
}
