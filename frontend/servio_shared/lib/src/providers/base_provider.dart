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

  /// Every record for a dropdown; reference lists are small, so one page of the maximum size is enough.
  Future<List<T>> getAll({Map<String, dynamic>? filter}) async => (await getPage(filter: filter, pageSize: 100)).items;

  Future<T> getById(int id) async => fromJson(await api.get('$endpoint/$id') as Map<String, dynamic>);
}

abstract class CrudProvider<T> extends ReadProvider<T> {
  CrudProvider(super.api, super.endpoint);

  Future<T> insert(Map<String, dynamic> request) async => fromJson(await api.post(endpoint, request) as Map<String, dynamic>);

  Future<T> update(int id, Map<String, dynamic> request) async =>
      fromJson(await api.put('$endpoint/$id', request) as Map<String, dynamic>);

  Future<void> delete(int id) => api.delete('$endpoint/$id');
}
