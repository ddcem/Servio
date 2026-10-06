import '../api/api_client.dart';
import '../models/order.dart';
import 'base_provider.dart';

class OrderProvider extends ReadProvider<Order> {
  OrderProvider(ApiClient api) : super(api, 'orders');

  @override
  Order fromJson(Map<String, dynamic> json) => Order.fromJson(json);

  /// [items]: `{menuItemId, quantity, note}`; [shownRecommendations]: suggestions the waiter saw.
  Future<Order> create(
    int tableId,
    int guestCount,
    List<Map<String, dynamic>> items,
    List<Map<String, dynamic>> shownRecommendations,
  ) async => fromJson(
    await api.post(endpoint, {
      'tableId': tableId,
      'guestCount': guestCount,
      'items': items,
      'shownRecommendations': shownRecommendations,
    }) as Map<String, dynamic>,
  );

  Future<Order> addItems(int id, List<Map<String, dynamic>> items, List<Map<String, dynamic>> shownRecommendations) async =>
      fromJson(
        await api.post('$endpoint/$id/items', {'items': items, 'shownRecommendations': shownRecommendations})
            as Map<String, dynamic>,
      );

  Future<Order> cancel(int id, String reason) async =>
      fromJson(await api.post('$endpoint/$id/cancel', {'reason': reason}) as Map<String, dynamic>);
}

class OrderTicketProvider extends ReadProvider<OrderTicket> {
  OrderTicketProvider(ApiClient api) : super(api, 'order-tickets');

  @override
  OrderTicket fromJson(Map<String, dynamic> json) => OrderTicket.fromJson(json);

  Future<OrderTicket> start(int id) async => fromJson(await api.post('$endpoint/$id/start') as Map<String, dynamic>);

  Future<OrderTicket> markReady(int id) async => fromJson(await api.post('$endpoint/$id/ready') as Map<String, dynamic>);

  Future<OrderTicket> serve(int id) async => fromJson(await api.post('$endpoint/$id/serve') as Map<String, dynamic>);

  Future<OrderTicket> cancel(int id, String reason) async =>
      fromJson(await api.post('$endpoint/$id/cancel', {'reason': reason}) as Map<String, dynamic>);

  Future<List<StationSummary>> getStationSummaries() async {
    final json = await api.get('$endpoint/station-summaries') as List;
    return json.map((e) => StationSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}
