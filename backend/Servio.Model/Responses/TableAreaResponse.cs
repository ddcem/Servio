namespace Servio.Model.Responses;

public class TableAreaResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    /// <summary>An area with tables cannot be deleted.</summary>
    public int TableCount { get; set; }
}
