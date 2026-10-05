using Microsoft.AspNetCore.Mvc;
using Servio.API.Controllers.Base;
using Servio.Model.Requests;
using Servio.Model.Responses;
using Servio.Model.SearchObjects;
using Servio.Services.Database.Entities;
using Servio.Services.ReferenceData;

namespace Servio.API.Controllers;

[Route("api/roles")]
public class RolesController(LookupService<Role> service)
    : BaseReadController<LookupResponse, BaseSearchObject>(service);

[Route("api/preparation-stations")]
public class PreparationStationsController(LookupService<PreparationStation> service)
    : BaseReadController<LookupResponse, BaseSearchObject>(service);

[Route("api/payment-methods")]
public class PaymentMethodsController(LookupService<PaymentMethod> service)
    : BaseReadController<LookupResponse, BaseSearchObject>(service);

[Route("api/table-areas")]
public class TableAreasController(ITableAreaService service)
    : BaseCrudController<TableAreaResponse, BaseSearchObject, NameUpsertRequest, NameUpsertRequest>(service);

[Route("api/item-tags")]
public class ItemTagsController(IItemTagService service)
    : BaseCrudController<ItemTagResponse, BaseSearchObject, NameUpsertRequest, NameUpsertRequest>(service);

[Route("api/menu-categories")]
public class MenuCategoriesController(IMenuCategoryService service)
    : BaseCrudController<MenuCategoryResponse, MenuCategorySearchObject, MenuCategoryUpsertRequest, MenuCategoryUpsertRequest>(service);

[Route("api/currencies")]
public class CurrenciesController(ICurrencyService service)
    : BaseCrudController<CurrencyResponse, BaseSearchObject, CurrencyUpsertRequest, CurrencyUpsertRequest>(service);
