import 'enums.dart';
import 'json.dart';

/// Read-only reference data: roles, preparation stations, payment methods.
class Lookup {
  const Lookup({required this.id, required this.name});

  factory Lookup.fromJson(Map<String, dynamic> json) => Lookup(id: json['id'] as int, name: json['name'] as String);

  final int id;
  final String name;
}

class TableArea {
  const TableArea({required this.id, required this.name, required this.tableCount});

  factory TableArea.fromJson(Map<String, dynamic> json) =>
      TableArea(id: json['id'] as int, name: json['name'] as String, tableCount: json['tableCount'] as int);

  final int id;
  final String name;
  final int tableCount;
}

class ItemTag {
  const ItemTag({required this.id, required this.name, required this.menuItemCount});

  factory ItemTag.fromJson(Map<String, dynamic> json) =>
      ItemTag(id: json['id'] as int, name: json['name'] as String, menuItemCount: json['menuItemCount'] as int);

  final int id;
  final String name;
  final int menuItemCount;
}

class MenuCategory {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.courseType,
    required this.preparationStationId,
    required this.preparationStationName,
    required this.sortOrder,
    required this.menuItemCount,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
    id: json['id'] as int,
    name: json['name'] as String,
    courseType: toEnum(CourseType.values, json['courseType']),
    preparationStationId: json['preparationStationId'] as int,
    preparationStationName: json['preparationStationName'] as String,
    sortOrder: json['sortOrder'] as int,
    menuItemCount: json['menuItemCount'] as int,
  );

  final int id;
  final String name;
  final CourseType courseType;
  final int preparationStationId;
  final String preparationStationName;
  final int sortOrder;
  final int menuItemCount;
}

class Currency {
  const Currency({required this.id, required this.code, required this.name, required this.symbol, required this.isInUse});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    symbol: json['symbol'] as String,
    isInUse: json['isInUse'] as bool,
  );

  final int id;
  final String code;
  final String name;
  final String symbol;
  final bool isInUse;
}

class RestaurantSettings {
  const RestaurantSettings({
    required this.restaurantName,
    required this.currencyId,
    required this.currencyCode,
    required this.currencySymbol,
    required this.taxRate,
    required this.updatedAt,
    this.updatedByName,
  });

  factory RestaurantSettings.fromJson(Map<String, dynamic> json) => RestaurantSettings(
    restaurantName: json['restaurantName'] as String,
    currencyId: json['currencyId'] as int,
    currencyCode: json['currencyCode'] as String,
    currencySymbol: json['currencySymbol'] as String,
    taxRate: toDouble(json['taxRate']),
    updatedAt: toLocalDate(json['updatedAt']),
    updatedByName: json['updatedByName'] as String?,
  );

  final String restaurantName;
  final int currencyId;
  final String currencyCode;
  final String currencySymbol;
  final double taxRate;
  final DateTime updatedAt;
  final String? updatedByName;
}
