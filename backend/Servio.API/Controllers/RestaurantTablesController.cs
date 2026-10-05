using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Tables;

namespace Servio.API.Controllers;

[Route("api/tables")]
public class RestaurantTablesController(IRestaurantTableService service)
    : BaseCrudController<RestaurantTableResponse, RestaurantTableSearchObject, RestaurantTableUpsertRequest, RestaurantTableUpsertRequest>(service);
