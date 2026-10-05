using Servio.Model.Enums;

namespace Servio.Model.SearchObjects;

public class RestaurantTableSearchObject : BaseSearchObject
{
    public int? AreaId { get; set; }
    public int? MinCapacity { get; set; }
    public bool? IsActive { get; set; }
    public TableStatus? Status { get; set; }
}
