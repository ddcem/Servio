import '../api/api_client.dart';
import '../models/notification.dart';
import 'base_provider.dart';

class NotificationProvider extends ReadProvider<AppNotification> {
  NotificationProvider(ApiClient api) : super(api, 'notifications');

  @override
  AppNotification fromJson(Map<String, dynamic> json) => AppNotification.fromJson(json);

  Future<int> getUnreadCount() async => (await api.get('$endpoint/unread-count') as Map<String, dynamic>)['count'] as int;

  Future<AppNotification> markAsRead(int id) async => fromJson(await api.put('$endpoint/$id/read') as Map<String, dynamic>);

  Future<void> markAllAsRead() => api.put('$endpoint/read-all');
}
