namespace Servio.Model.SearchObjects;

public class BaseSearchObject
{
    public const int MaxPageSize = 100;

    private int _page = 1;
    private int _pageSize = 20;

    public string? FTS { get; set; }

    public int Page
    {
        get => _page;
        set => _page = Math.Max(1, value);
    }

    public int PageSize
    {
        get => _pageSize;
        set => _pageSize = Math.Clamp(value, 1, MaxPageSize);
    }
}
