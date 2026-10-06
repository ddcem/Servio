import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notification.dart';
import '../providers/notification_provider.dart';
import '../realtime/realtime_service.dart';

/// Unread badge and live notifications for the logged-in user. New notifications arrive
/// over SignalR, so the count updates without a manual refresh.
class NotificationCenter extends ChangeNotifier {
  NotificationCenter(this.provider, this.realtime) {
    _subscription = realtime.notifications.listen((notification) {
      _unreadCount++;
      _latest = notification;
      notifyListeners();
    });
  }

  final NotificationProvider provider;
  final RealtimeService realtime;
  late final StreamSubscription<AppNotification> _subscription;

  int _unreadCount = 0;
  AppNotification? _latest;

  int get unreadCount => _unreadCount;

  /// The most recent notification pushed while the app is open; null once shown.
  AppNotification? takeLatest() {
    final latest = _latest;
    _latest = null;
    return latest;
  }

  Future<void> refreshCount() async {
    _unreadCount = await provider.getUnreadCount();
    notifyListeners();
  }

  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    await provider.markAsRead(notification.id);
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await provider.markAllAsRead();
    _unreadCount = 0;
    notifyListeners();
  }

  void reset() {
    _unreadCount = 0;
    _latest = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
