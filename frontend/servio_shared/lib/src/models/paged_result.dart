import 'json.dart';

class PagedResult<T> {
  const PagedResult({required this.items, required this.totalCount, required this.page, required this.pageSize});

  factory PagedResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) => PagedResult(
    items: toList(json['items'], fromJson),
    totalCount: json['totalCount'] as int,
    page: json['page'] as int,
    pageSize: json['pageSize'] as int,
  );

  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  int get pageCount => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
}
