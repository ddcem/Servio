using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Base;

namespace Servio.Services.Tables;

public interface IRestaurantTableService
    : ICrudService<RestaurantTableResponse, RestaurantTableSearchObject, RestaurantTableUpsertRequest, RestaurantTableUpsertRequest>;
