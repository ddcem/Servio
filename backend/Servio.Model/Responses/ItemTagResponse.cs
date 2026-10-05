namespace Servio.Model.Responses;

public class ItemTagResponse
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    /// <summary>A tag used by menu items cannot be deleted.</summary>
    public int MenuItemCount { get; set; }
}
