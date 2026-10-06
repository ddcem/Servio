import 'enums.dart';
import 'json.dart';
import 'reference_data.dart';

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.courseType,
    required this.preparationStationId,
    required this.preparationStationName,
    required this.isAvailableToday,
    required this.hasImage,
    required this.isFavorite,
    required this.soldByMeCount,
    required this.tags,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
    price: toDouble(json['price']),
    categoryId: json['categoryId'] as int,
    categoryName: json['categoryName'] as String,
    courseType: toEnum(CourseType.values, json['courseType']),
    preparationStationId: json['preparationStationId'] as int,
    preparationStationName: json['preparationStationName'] as String,
    isAvailableToday: json['isAvailableToday'] as bool,
    hasImage: json['hasImage'] as bool,
    isFavorite: json['isFavorite'] as bool,
    soldByMeCount: json['soldByMeCount'] as int? ?? 0,
    tags: toList(json['tags'], Lookup.fromJson),
  );

  final int id;
  final String name;
  final String? description;
  final double price;
  final int categoryId;
  final String categoryName;
  final CourseType courseType;
  final int preparationStationId;
  final String preparationStationName;
  final bool isAvailableToday;
  final bool hasImage;
  final bool isFavorite;
  final int soldByMeCount;
  final List<Lookup> tags;

  bool get isDrink => courseType == CourseType.drink;

  MenuItem copyWith({bool? isFavorite, bool? isAvailableToday}) => MenuItem(
    id: id,
    name: name,
    description: description,
    price: price,
    categoryId: categoryId,
    categoryName: categoryName,
    courseType: courseType,
    preparationStationId: preparationStationId,
    preparationStationName: preparationStationName,
    isAvailableToday: isAvailableToday ?? this.isAvailableToday,
    hasImage: hasImage,
    isFavorite: isFavorite ?? this.isFavorite,
    soldByMeCount: soldByMeCount,
    tags: tags,
  );
}

/// An upselling suggestion with the explanation shown to the waiter.
class Recommendation {
  const Recommendation({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.categoryName,
    required this.courseType,
    required this.hasImage,
    required this.score,
    required this.reason,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
    menuItemId: json['menuItemId'] as int,
    name: json['name'] as String,
    price: toDouble(json['price']),
    categoryName: json['categoryName'] as String,
    courseType: toEnum(CourseType.values, json['courseType']),
    hasImage: json['hasImage'] as bool,
    score: toDouble(json['score']),
    reason: json['reason'] as String,
  );

  final int menuItemId;
  final String name;
  final double price;
  final String categoryName;
  final CourseType courseType;
  final bool hasImage;
  final double score;
  final String reason;
}
