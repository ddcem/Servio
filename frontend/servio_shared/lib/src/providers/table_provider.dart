import '../api/api_client.dart';
import '../models/reservation.dart';
import '../models/restaurant_table.dart';
import 'base_provider.dart';

class RestaurantTableProvider extends CrudProvider<RestaurantTable> {
  RestaurantTableProvider(ApiClient api) : super(api, 'tables');

  @override
  RestaurantTable fromJson(Map<String, dynamic> json) => RestaurantTable.fromJson(json);

  /// Gives tables to waiters for the current shift; a null waiter means any waiter may serve the table.
  Future<void> assign(Map<int, int?> waiterByTableId) => api.put('$endpoint/assignments', {
    'items': [
      for (final MapEntry(key: tableId, value: waiterId) in waiterByTableId.entries) {'tableId': tableId, 'waiterId': waiterId},
    ],
  });
}

/// Reservations are never deleted; they move through confirm / complete / no-show / cancel.
class ReservationProvider extends ReadProvider<Reservation> {
  ReservationProvider(ApiClient api) : super(api, 'reservations');

  @override
  Reservation fromJson(Map<String, dynamic> json) => Reservation.fromJson(json);

  Future<Reservation> insert(Map<String, dynamic> request) async =>
      fromJson(await api.post(endpoint, request) as Map<String, dynamic>);

  Future<Reservation> update(int id, Map<String, dynamic> request) async =>
      fromJson(await api.put('$endpoint/$id', request) as Map<String, dynamic>);

  Future<Reservation> confirm(int id) async => fromJson(await api.post('$endpoint/$id/confirm') as Map<String, dynamic>);

  Future<Reservation> complete(int id) async => fromJson(await api.post('$endpoint/$id/complete') as Map<String, dynamic>);

  Future<Reservation> markNoShow(int id) async => fromJson(await api.post('$endpoint/$id/no-show') as Map<String, dynamic>);

  Future<Reservation> cancel(int id, String reason) async =>
      fromJson(await api.post('$endpoint/$id/cancel', {'reason': reason}) as Map<String, dynamic>);
}
