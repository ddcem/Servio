import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';

/// The admin's notifications (payments, refunds…); new ones appear live.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationProvider _notifications = context.read<NotificationProvider>();
  late final StreamSubscription<AppNotification> _live;

  PagedResult<AppNotification>? _result;
  Object? _error;
  int _page = 1;
  bool? _isRead;

  @override
  void initState() {
    super.initState();
    _live = context.read<RealtimeService>().notifications.listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    _live.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final result = await _notifications.getPage(page: _page, filter: {'IsRead': _isRead});
      if (mounted) {
        setState(() {
          _result = result;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _markRead(AppNotification notification) async {
    try {
      await context.read<NotificationCenter>().markAsRead(notification);
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await context.read<NotificationCenter>().markAllAsRead();
      if (mounted) showSuccess(context, l10n.allMarkedRead);
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) {
    final unread = context.watch<NotificationCenter>().unreadCount;
    return AdminPage(
      title: l10n.notifications,
      subtitle: unread == 0 ? l10n.youAreAllCaughtUp : l10n.unreadCount(unread),
      actions: [
        OutlinedButton.icon(
          onPressed: unread == 0 ? null : _markAllRead,
          icon: const Icon(Icons.done_all),
          label: Text(l10n.markAllAsRead),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          FilterDropdown<bool>(
            label: l10n.show,
            value: _isRead,
            items: {false: l10n.unread, true: l10n.read},
            onChanged: (value) {
              setState(() {
                _isRead = value;
                _page = 1;
              });
              _load();
            },
          ),
          const SizedBox(height: 20),
          if (_error != null && _result == null)
            ErrorView(error: _error!, onRetry: _load)
          else if (_result == null)
            const LoadingView()
          else if (_result!.items.isEmpty)
            EmptyView(icon: Icons.notifications_none, message: l10n.noNotifications)
          else ...[
            for (final n in _result!.items)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                color: n.isRead ? Colors.white : const Color(0xFFEFF6FF),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Icon(
                    n.isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: n.isRead ? ServioColors.textMuted : ServioColors.primary,
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text('${n.body}\n${Formatters.relative(n.createdAt)}'),
                  isThreeLine: true,
                  trailing: n.isRead
                      ? Text(l10n.read, style: const TextStyle(color: ServioColors.textMuted))
                      : TextButton(onPressed: () => _markRead(n), child: Text(l10n.markAsRead)),
                ),
              ),
            Pager(
              page: _page,
              pageCount: _result!.pageCount,
              totalCount: _result!.totalCount,
              onChanged: (page) {
                setState(() => _page = page);
                _load();
              },
            ),
          ],
        ],
      ),
    );
  }
}
