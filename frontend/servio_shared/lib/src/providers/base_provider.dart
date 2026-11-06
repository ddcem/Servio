import '../api/api_client.dart';
import '../models/paged_result.dart';

/// Paged, filtered reads of one API resource. [filter] keys are the API's search
/// parameters (e.g. `FTS`, `CategoryId`); null and empty values are left out.
abstract class ReadProvider<T> {
  ReadProvider(this.api, this.endpoint);

  final ApiClient api;
  final String endpoint;

  T fromJson(Map<String, dynamic> json);

  Future<PagedResult<T>> getPage({Map<String, dynamic>? filter, int page = 1, int pageSize = 20}) async {
    final json = await api.get(endpoint, query: {...?filter, 'page': page, 'pageSize': pageSize});
    return PagedResult.fromJson(json as Map<String, dynamic>, fromJson);
  }

  /// Largest page the API returns (BaseSearchObject.MaxPageSize on the server).
  static const maxPageSize = 100;

  /// Every matching record (the whole menu, all tables…): pages are loaded one after another until
  /// [PagedResult.totalCount] is reached, because the API never returns more than [maxPageSize] at once.
  Future<List<T>> getAll({Map<String, dynamic>? filter}) async {
    final items = <T>[];
    for (var page = 1; ; page++) {
      final result = await getPage(filter: filter, page: page, pageSize: maxPageSize);
      items.addAll(result.items);
      if (result.items.isEmpty || items.length >= result.totalCount) return items;
    }
  }

  Future<T> getById(int id) async => fromJson(await api.get('$endpoint/$id') as Map<String, dynamic>);
}

abstract class CrudProvider<T> extends ReadProvider<T> {
  CrudProvider(super.api, super.endpoint);

  Future<T> insert(Map<String, dynamic> request) async => fromJson(await api.post(endpoint, request) as Map<String, dynamic>);

  Future<T> update(int id, Map<String, dynamic> request) async =>
      fromJson(await api.put('$endpoint/$id', request) as Map<String, dynamic>);

  Future<void> delete(int id) => api.delete('$endpoint/$id');
}
