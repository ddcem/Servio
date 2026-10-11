import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import 'employees_screen.dart';
import 'menu_management_screen.dart';
import 'notifications_screen.dart';
import 'orders_screen.dart';
import 'reference_data_screen.dart';
import 'reports_screen.dart';
import 'reservations_screen.dart';
import 'settings_screen.dart';
import 'tables_screen.dart';

class _Section {
  const _Section(this.label, this.icon, this.builder);

  final String label;
  final IconData icon;
  final Widget Function() builder;
}

/// The admin panel: a sidebar with every management section, as in the design.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  static List<_Section> get _sections => [
    _Section(l10n.menuManagement, Icons.inventory_2_outlined, () => const MenuManagementScreen()),
    _Section(l10n.employees, Icons.people_outline, () => const EmployeesScreen()),
    _Section(l10n.tables, Icons.table_restaurant_outlined, () => const TablesScreen()),
    _Section(l10n.reservations, Icons.event_outlined, () => const ReservationsScreen()),
    _Section(l10n.ordersAndPayments, Icons.receipt_long_outlined, () => const OrdersScreen()),
    _Section(l10n.referenceData, Icons.category_outlined, () => const ReferenceDataScreen()),
    _Section(l10n.reports, Icons.bar_chart, () => const ReportsScreen()),
    _Section(l10n.notifications, Icons.notifications_outlined, () => const NotificationsScreen()),
    _Section(l10n.settings, Icons.settings_outlined, () => const SettingsScreen()),
  ];

  static const _notificationsIndex = 7;

  int _index = 0;
  late final StreamSubscription<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    context.read<NotificationCenter>().refreshCount();
    _notifications = context.read<RealtimeService>().notifications.listen((notification) {
      if (mounted) showSuccess(context, l10n.notificationLine(notification.title, notification.body));
    });
  }

  @override
  void dispose() {
    _notifications.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final user = context.watch<AuthProvider>().user;
    // Right after logout this screen is built once more before the app returns to the login screen.
    if (user == null) return const SizedBox.shrink();
    final unread = context.watch<NotificationCenter>().unreadCount;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 280,
            color: ServioColors.sidebar,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: ServioColors.primary,
                        child: Icon(Icons.verified_user_outlined, color: Colors.white),
                      ),
                      SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.adminPanel,
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(l10n.systemManagement, style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                _NavTile(
                  icon: Icons.arrow_back,
                  label: l10n.backToDashboard,
                  selected: false,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (var i = 0; i < _sections.length; i++)
                        _NavTile(
                          icon: _sections[i].icon,
                          label: _sections[i].label,
                          selected: i == _index,
                          badge: i == _notificationsIndex && unread > 0 ? unread : null,
                          onTap: () => setState(() => _index = i),
                        ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.loggedInAs(Roles.label(user.role)), style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      Text(
                        user.fullName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                _NavTile(
                  icon: Icons.logout,
                  label: l10n.logout,
                  selected: false,
                  onTap: () => context.read<AuthProvider>().logout(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: KeyedSubtree(key: ValueKey(_index), child: _sections[_index].builder()),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.icon, required this.label, required this.selected, required this.onTap, this.badge});

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    child: Material(
      color: selected ? ServioColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              Icon(icon, color: selected ? Colors.white : Colors.white70, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: ServioColors.danger, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '$badge',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
