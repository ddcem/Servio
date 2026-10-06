/// Helpers for reading API JSON: decimals arrive as numbers, timestamps as UTC ISO strings,
/// enums as their C# names (e.g. "Preparing").
double toDouble(Object? value) => (value as num?)?.toDouble() ?? 0;

double? toDoubleOrNull(Object? value) => (value as num?)?.toDouble();

DateTime toLocalDate(Object? value) => DateTime.parse(value as String).toLocal();

DateTime? toLocalDateOrNull(Object? value) => value == null ? null : DateTime.parse(value as String).toLocal();

T toEnum<T extends Enum>(List<T> values, Object? name) =>
    values.firstWhere((e) => e.name.toLowerCase() == (name as String).toLowerCase());

/// The C# name of a Dart enum value, as the API expects it in requests and filters.
String enumToApi(Enum value) => value.name[0].toUpperCase() + value.name.substring(1);

List<T> toList<T>(Object? value, T Function(Map<String, dynamic>) fromJson) =>
    (value as List? ?? const []).map((e) => fromJson(e as Map<String, dynamic>)).toList();
