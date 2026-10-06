import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import 'active_orders_screen.dart';
import 'menu_screen.dart';
import 'notifications_screen.dart';
import 'onboarding_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';
import 'table_order_screen.dart';

/// The waiter's home: every table with its live status. Tapping a free table starts an order,
/// tapping an occupied one opens its order.
class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  late final _tables = context.read<RestaurantTableProvider>();
  late final StreamSubscription<String> _changes;
  late final StreamSubscription<AppNotification> _notifications;

  List<RestaurantTable>? _items;
  String _currency = '';
  Object? _error;
  String? _area;

  @override
  void initState() {
    super.initState();
    final realtime = context.read<RealtimeService>();
    _changes = realtime.whereEvent({RealtimeEvents.ordersChanged, RealtimeEvents.reservationsChanged}).listen((_) => _load());
    _notifications = realtime.notifications.listen(_onNotification);
    context.read<NotificationCenter>().refreshCount();
    _load();
  }

  @override
  void dispose() {
    _changes.cancel();
    _notifications.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final settings = context.read<SettingsProvider>().get();
      final items = await _tables.getAll(filter: {'IsActive': true});
      final currency = (await settings).currencySymbol;
      if (mounted) {
        setState(() {
          _items = items;
          _currency = currency;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _onNotification(AppNotification notification) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
          backgroundColor: notification.type == NotificationType.ticketCancelled ? ServioColors.danger : ServioColors.success,
          content: Text('${notification.title}\n${notification.body}'),
          action: notification.orderTicketId == null
              ? null
              : SnackBarAction(label: 'OPEN', textColor: Colors.white, onPressed: () => _open(const ActiveOrdersScreen())),
        ),
      );
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  Future<void> _onTableTap(RestaurantTable table) async {
    if (table.currentOrderId != null) {
      return _open(TableOrderScreen(orderId: table.currentOrderId!));
    }

    final reservation = table.upcomingReservation;
    final guests = await showDialog<int>(
      context: context,
      builder: (_) => _GuestCountDialog(table: table, initial: reservation?.partySize ?? 2),
    );
    if (guests != null && mounted) {
      await _open(MenuScreen(tableId: table.id, tableNumber: table.number, guestCount: guests));
    }
  }

  Future<void> _logout() async {
    final confirmed = await confirmAction(context, title: 'Logout', message: 'Do you want to log out?', confirmLabel: 'Logout');
    if (confirmed && mounted) await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationCenter>().unreadCount;
    final areas = {for (final table in _items ?? <RestaurantTable>[]) table.areaName}.toList();
    final visible = (_items ?? []).where((table) => _area == null || table.areaName == _area).toList();

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Servio',
        subtitle: 'Welcome, ${user?.firstName ?? ''}',
        actions: [
          HeaderButton(
            icon: Icons.receipt_long_outlined,
            tooltip: 'My active tables',
            onPressed: () => _open(const ActiveOrdersScreen()),
          ),
          HeaderButton(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            badge: unread,
            onPressed: () => _open(const NotificationsScreen()),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => switch (value) {
              'profile' => _open(const ProfileScreen()),
              'history' => _open(const OrderHistoryScreen()),
              'guide' => _open(OnboardingScreen(onDone: () => Navigator.of(context).pop())),
              _ => _logout(),
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'history',
                child: ListTile(leading: Icon(Icons.history), title: Text('Order history')),
              ),
              PopupMenuItem(
                value: 'profile',
                child: ListTile(leading: Icon(Icons.person_outline), title: Text('My profile')),
              ),
              PopupMenuItem(
                value: 'guide',
                child: ListTile(leading: Icon(Icons.help_outline), title: Text('Waiter guide')),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
              ),
            ],
          ),
        ],
      ),
      body: _error != null && _items == null
          ? ErrorView(error: _error!, onRetry: _load)
          : _items == null
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Table Status', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Wrap(
                            spacing: 14,
                            children: [
                              _Legend(ServioColors.available, 'Available'),
                              _Legend(ServioColors.occupied, 'Occupied'),
                              _Legend(ServioColors.reserved, 'Reserved'),
                            ],
                          ),
                          if (areas.length > 1) ...[
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final area in [null, ...areas])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(area ?? 'All areas'),
                                        selected: _area == area,
                                        onSelected: (_) => setState(() => _area = area),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    const SliverFillRemaining(
                      child: EmptyView(icon: Icons.table_restaurant_outlined, message: 'No tables are in use.'),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisExtent: 216,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (_, index) =>
                            _TableCard(table: visible[index], currency: _currency, onTap: () => _onTableTap(visible[index])),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      ),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.currency, required this.onTap});

  final RestaurantTable table;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, background, badge) = switch (table.status) {
      TableStatus.available => (ServioColors.available, const Color(0xFFF0FDF4), 'AVAIL'),
      TableStatus.occupied => (ServioColors.occupied, const Color(0xFFFEF2F2), 'OCC'),
      TableStatus.reserved => (ServioColors.reserved, const Color(0xFFFEFCE8), 'RES'),
    };
    final reservation = table.upcomingReservation;
    final total = table.currentOrderTotal;

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.55), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Table',
                      style: TextStyle(color: ServioColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Text('${table.number}', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 4),
              _info(Icons.people_outline, 'Max: ${table.capacity}'),
              if (table.currentGuestCount != null)
                _info(Icons.people, 'Now: ${table.currentGuestCount}', bold: true)
              else if (reservation != null)
                _info(Icons.schedule, '${Formatters.time(reservation.startTime)} · ${reservation.partySize} guests', bold: true),
              Text(table.areaName, style: const TextStyle(color: ServioColors.textMuted, fontSize: 12)),
              const Spacer(),
              if (total != null) ...[
                const Divider(height: 12),
                Row(
                  children: [
                    const Expanded(child: Text('Total', style: TextStyle(fontSize: 12))),
                    Text(
                      Formatters.money(total, currency),
                      style: const TextStyle(color: ServioColors.primary, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right, color: ServioColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _info(IconData icon, String text, {bool bold = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        Icon(icon, size: 16, color: ServioColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.normal),
          ),
        ),
      ],
    ),
  );
}

/// How many guests sit down; at most the table's capacity.
class _GuestCountDialog extends StatefulWidget {
  const _GuestCountDialog({required this.table, required this.initial});

  final RestaurantTable table;
  final int initial;

  @override
  State<_GuestCountDialog> createState() => _GuestCountDialogState();
}

class _GuestCountDialogState extends State<_GuestCountDialog> {
  late int _guests = widget.initial.clamp(1, widget.table.capacity);

  @override
  Widget build(BuildContext context) {
    final reservation = widget.table.upcomingReservation;
    return AlertDialog(
      title: Text('Table ${widget.table.number}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reservation != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ServioColors.warningLight, borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Reserved for ${reservation.guestName} at ${Formatters.time(reservation.startTime)} '
                '(${reservation.partySize} guests).',
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text('How many guests?'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Fewer guests',
                onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '$_guests',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'More guests',
                onPressed: _guests < widget.table.capacity ? () => setState(() => _guests++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Text('The table seats ${widget.table.capacity}.', style: const TextStyle(color: ServioColors.textMuted)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
        FilledButton(onPressed: () => Navigator.pop(context, _guests), child: const Text('Start order')),
      ],
    );
  }
}
