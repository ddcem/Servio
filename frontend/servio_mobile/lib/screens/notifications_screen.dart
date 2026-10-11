import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';

/// The waiter's inbox: orders ready at the kitchen or bar, cancelled tickets, payments.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final _center = context.read<NotificationCenter>();
  late final StreamSubscription<AppNotification> _live;
  final _items = <AppNotification>[];
  bool _unreadOnly = false;
  bool _loading = true;
  bool _hasMore = true;
  int _page = 1;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _live = context.read<RealtimeService>().notifications.listen((_) => _reload());
    _reload();
  }

  @override
  void dispose() {
    _live.cancel();
    super.dispose();
  }

  Future<void> _reload() async {
    _page = 1;
    _hasMore = true;
    await _loadPage(replace: true);
  }

  Future<void> _loadPage({bool replace = false}) async {
    setState(() => _loading = true);
    try {
      final result = await _center.provider.getPage(filter: {if (_unreadOnly) 'IsRead': false}, page: _page);
      if (!mounted) return;
      setState(() {
        if (replace) _items.clear();
        _items.addAll(result.items);
        _hasMore = _items.length < result.totalCount;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markRead(int index) async {
    final notification = _items[index];
    if (notification.isRead) return;
    try {
      await _center.markAsRead(notification);
      await _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _center.markAllAsRead();
      await _reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationCenter>().unreadCount;
    return Scaffold(
      appBar: GradientAppBar(
        title: l10n.notifications,
        subtitle: unread == 0 ? l10n.allCaughtUp : l10n.unreadCount(unread),
        actions: [if (unread > 0) HeaderButton(icon: Icons.done_all, tooltip: l10n.markAllAsRead, onPressed: _markAllRead)],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.all)),
                ButtonSegment(value: true, label: Text(l10n.unread)),
              ],
              selected: {_unreadOnly},
              onSelectionChanged: (value) {
                setState(() => _unreadOnly = value.first);
                _reload();
              },
            ),
          ),
          Expanded(
            child: _error != null && _items.isEmpty
                ? ErrorView(error: _error!, onRetry: _reload)
                : _items.isEmpty && _loading
                ? LoadingView()
                : RefreshIndicator(
                    onRefresh: _reload,
                    child: _items.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: 100),
                              EmptyView(icon: Icons.notifications_none, message: l10n.noNotifications),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _items.length + (_hasMore ? 1 : 0),
                            itemBuilder: (_, index) {
                              if (index == _items.length) {
                                return Center(
                                  child: TextButton(
                                    onPressed: _loading
                                        ? null
                                        : () {
                                            _page++;
                                            _loadPage();
                                          },
                                    child: Text(l10n.loadMore),
                                  ),
                                );
                              }
                              return _NotificationTile(notification: _items[index], onTap: () => _markRead(index));
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notification.type) {
      NotificationType.ticketReady => (Icons.room_service, ServioColors.success),
      NotificationType.ticketCancelled => (Icons.cancel, ServioColors.danger),
      NotificationType.paymentCompleted || NotificationType.refundIssued => (Icons.payments, ServioColors.primary),
      NotificationType.tablesAssigned => (Icons.person_pin_outlined, ServioColors.primary),
      _ => (Icons.notifications, ServioColors.primary),
    };
    return Card(
      color: notification.isRead ? Colors.white : const Color(0xFFEFF6FF),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold)),
        subtitle: Text('${notification.body}\n${Formatters.relative(notification.createdAt)}'),
        isThreeLine: true,
        trailing: notification.isRead ? null : const Icon(Icons.circle, size: 10, color: ServioColors.primary),
        onTap: onTap,
      ),
    );
  }
}
