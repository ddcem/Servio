import '../api/api_client.dart';
import '../models/reference_data.dart';
import 'base_provider.dart';

class RoleProvider extends ReadProvider<Lookup> {
  RoleProvider(ApiClient api) : super(api, 'roles');

  @override
  Lookup fromJson(Map<String, dynamic> json) => Lookup.fromJson(json);
}

class PreparationStationProvider extends ReadProvider<Lookup> {
  PreparationStationProvider(ApiClient api) : super(api, 'preparation-stations');

  @override
  Lookup fromJson(Map<String, dynamic> json) => Lookup.fromJson(json);
}

class PaymentMethodProvider extends ReadProvider<Lookup> {
  PaymentMethodProvider(ApiClient api) : super(api, 'payment-methods');

  @override
  Lookup fromJson(Map<String, dynamic> json) => Lookup.fromJson(json);
}

class TableAreaProvider extends CrudProvider<TableArea> {
  TableAreaProvider(ApiClient api) : super(api, 'table-areas');

  @override
  TableArea fromJson(Map<String, dynamic> json) => TableArea.fromJson(json);
}

class ItemTagProvider extends CrudProvider<ItemTag> {
  ItemTagProvider(ApiClient api) : super(api, 'item-tags');

  @override
  ItemTag fromJson(Map<String, dynamic> json) => ItemTag.fromJson(json);
}

class MenuCategoryProvider extends CrudProvider<MenuCategory> {
  MenuCategoryProvider(ApiClient api) : super(api, 'menu-categories');

  @override
  MenuCategory fromJson(Map<String, dynamic> json) => MenuCategory.fromJson(json);
}

class CurrencyProvider extends CrudProvider<Currency> {
  CurrencyProvider(ApiClient api) : super(api, 'currencies');

  @override
  Currency fromJson(Map<String, dynamic> json) => Currency.fromJson(json);
}

class SettingsProvider {
  SettingsProvider(this.api);

  final ApiClient api;

  Future<RestaurantSettings> get() async => RestaurantSettings.fromJson(await api.get('settings') as Map<String, dynamic>);

  Future<RestaurantSettings> update(Map<String, dynamic> request) async =>
      RestaurantSettings.fromJson(await api.put('settings', request) as Map<String, dynamic>);
}
