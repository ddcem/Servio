import '../api/api_client.dart';

import 'dart:typed_data';

import '../models/menu_item.dart';
import 'base_provider.dart';

class MenuItemProvider extends CrudProvider<MenuItem> {
  MenuItemProvider(ApiClient api) : super(api, 'menu-items');

  @override
  MenuItem fromJson(Map<String, dynamic> json) => MenuItem.fromJson(json);

  Future<MenuItem> setAvailability(int id, bool isAvailableToday) async =>
      fromJson(await api.put('$endpoint/$id/availability', {'isAvailableToday': isAvailableToday}) as Map<String, dynamic>);

  String imageUrl(int id) => api.uri('$endpoint/$id/image').toString();

  Future<void> uploadImage(int id, Uint8List bytes, String fileName) => api.putFile('$endpoint/$id/image', bytes, fileName);

  Future<void> deleteImage(int id) => api.delete('$endpoint/$id/image');

  Future<void> setFavorite(int id, bool favorite) =>
      favorite ? api.put('$endpoint/$id/favorite') : api.delete('$endpoint/$id/favorite');

  Future<List<Recommendation>> recommend(int sourceMenuItemId, List<int> cartMenuItemIds, {int take = 3}) async {
    final json = await api.post('recommendations', {
      'sourceMenuItemId': sourceMenuItemId,
      'cartMenuItemIds': cartMenuItemIds,
      'take': take,
    }) as List;
    return json.map((e) => Recommendation.fromJson(e as Map<String, dynamic>)).toList();
  }
}
