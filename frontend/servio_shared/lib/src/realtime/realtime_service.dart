import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../models/notification.dart';

/// Event names pushed by the API (see RealtimeEvents on the server).
abstract final class RealtimeEvents {
  static const notificationReceived = 'NotificationReceived';
  static const ticketsChanged = 'TicketsChanged';
  static const ordersChanged = 'OrdersChanged';
  static const reservationsChanged = 'ReservationsChanged';
  static const menuChanged = 'MenuChanged';
}

/// Live connection to the API's SignalR hub. Screens listen to [changes] and reload
/// when their data changed; personal notifications arrive on [notifications].
class RealtimeService {
  RealtimeService(this.baseUrl);

  final String baseUrl;
  HubConnection? _connection;

  final _changes = StreamController<String>.broadcast();
  final _notifications = StreamController<AppNotification>.broadcast();

  Stream<String> get changes => _changes.stream;
  Stream<AppNotification> get notifications => _notifications.stream;

  /// Only the events in [events], e.g. `whereEvent({RealtimeEvents.ticketsChanged})`.
  Stream<String> whereEvent(Set<String> events) => changes.where(events.contains);

  Future<void> connect(String token) async {
    await disconnect();

    final connection = HubConnectionBuilder()
        .withUrl('$baseUrl/hubs/notifications', options: HttpConnectionOptions(accessTokenFactory: () async => token))
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
        .build();

    for (final event in [
      RealtimeEvents.ticketsChanged,
      RealtimeEvents.ordersChanged,
      RealtimeEvents.reservationsChanged,
      RealtimeEvents.menuChanged,
    ]) {
      connection.on(event, (_) => _changes.add(event));
    }

    connection.on(RealtimeEvents.notificationReceived, (arguments) {
      final json = arguments?.firstOrNull;
      if (json is Map) {
        _notifications.add(AppNotification.fromJson(Map<String, dynamic>.from(json)));
      }
    });

    // After a reconnect the client may have missed events, so every screen reloads.
    connection.onreconnected(({connectionId}) {
      for (final event in [RealtimeEvents.ticketsChanged, RealtimeEvents.ordersChanged, RealtimeEvents.reservationsChanged]) {
        _changes.add(event);
      }
    });

    _connection = connection;
    try {
      await connection.start();
    } catch (e) {
      debugPrint('Realtime connection failed: $e');
    }
  }

  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      await connection.stop();
    }
  }
}
