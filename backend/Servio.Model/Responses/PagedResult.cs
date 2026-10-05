namespace Servio.Model.Responses;

public class PagedResult<T>
{
    public required List<T> Items { get; init; }
    public int TotalCount { get; init; }
    public int Page { get; init; }
    public int PageSize { get; init; }
}
