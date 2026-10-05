namespace Servio.Services.Tables;

public static class TableRules
{
    /// <summary>A table shows as Reserved this long before a confirmed reservation starts.</summary>
    public static readonly TimeSpan ReservedHoldBeforeStart = TimeSpan.FromMinutes(60);
}
