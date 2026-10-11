import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import 'active_orders_screen.dart';
import 'menu_screen.dart';
import 'notifications_screen.dart';
import 'order_history_screen.dart';
import 'settings_screen.dart';
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

  /// Only the tables assigned to this waiter; switched on automatically when the admin has assigned some.
  bool? _mineOnly;

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
        final me = context.read<AuthProvider>().user?.id;
        setState(() {
          _items = items;
          _currency = currency;
          _mineOnly ??= items.any((t) => t.assignedWaiterId == me) ? true : null;
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
    final me = context.read<AuthProvider>().user!.id;
    if (!table.isServableBy(me)) {
      // Blocked on the server too; the waiter is told why instead of getting an error later.
      showError(context, ApiException(l10n.tableServedBy(table.number, table.assignedWaiterName ?? '?')));
      return;
    }
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
    final confirmed = await confirmAction(context, title: l10n.logout, message: l10n.logoutQuestion, confirmLabel: l10n.logout);
    if (confirmed && mounted) await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationCenter>().unreadCount;
    final areas = {for (final table in _items ?? <RestaurantTable>[]) table.areaName}.toList();
    final me = user?.id;
    final hasAssignments = (_items ?? []).any((t) => t.assignedWaiterId != null);
    final mineOnly = hasAssignments && (_mineOnly ?? false);
    final visible = (_items ?? [])
        .where((table) => _area == null || table.areaName == _area)
        .where((table) => !mineOnly || table.assignedWaiterId == me)
        .toList();

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Servio',
        subtitle: l10n.welcomeName(user?.firstName ?? ''),
        actions: [
          HeaderButton(
            icon: Icons.receipt_long_outlined,
            tooltip: l10n.myActiveTables,
            onPressed: () => _open(const ActiveOrdersScreen()),
          ),
          HeaderButton(
            icon: Icons.notifications_outlined,
            tooltip: l10n.notifications,
            badge: unread,
            onPressed: () => _open(const NotificationsScreen()),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.more,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) => switch (value) {
              'history' => _open(const OrderHistoryScreen()),
              'settings' => _open(const SettingsScreen()),
              _ => _logout(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'history',
                child: ListTile(leading: const Icon(Icons.history), title: Text(l10n.orderHistory)),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(leading: const Icon(Icons.settings_outlined), title: Text(l10n.settings)),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(leading: const Icon(Icons.logout), title: Text(l10n.logout)),
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
                          Text(l10n.tableStatus, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 14,
                            children: [
                              _Legend(ServioColors.available, l10n.available),
                              _Legend(ServioColors.occupied, l10n.occupied),
                              _Legend(ServioColors.reserved, l10n.reserved),
                            ],
                          ),
                          if (areas.length > 1 || hasAssignments) ...[
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (hasAssignments) ...[
                                    for (final (mine, label) in [(true, l10n.myTables), (false, l10n.allTables)])
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: ChoiceChip(
                                          avatar: mine ? const Icon(Icons.person_pin_outlined, size: 18) : null,
                                          label: Text(label),
                                          selected: mineOnly == mine,
                                          onSelected: (_) => setState(() => _mineOnly = mine),
                                        ),
                                      ),
                                    const SizedBox(height: 32, child: VerticalDivider(width: 16)),
                                  ],
                                  for (final area in [null, ...areas])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(area ?? l10n.allAreas),
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
                  if (visible.isEmpty && mineOnly)
                    SliverFillRemaining(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmptyView(icon: Icons.person_pin_outlined, message: l10n.noTablesAssignedToYou),
                          OutlinedButton(onPressed: () => setState(() => _mineOnly = false), child: Text(l10n.allTables)),
                        ],
                      ),
                    )
                  else if (visible.isEmpty)
                    SliverFillRemaining(
                      child: EmptyView(icon: Icons.table_restaurant_outlined, message: l10n.noTablesInUse),
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
                        itemBuilder: (_, index) => _TableCard(
                          table: visible[index],
                          currency: _currency,
                          me: me,
                          onTap: () => _onTableTap(visible[index]),
                        ),
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
  const _TableCard({required this.table, required this.currency, required this.me, required this.onTap});

  final RestaurantTable table;
  final String currency;
  final int? me;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, background, badge) = switch (table.status) {
      TableStatus.available => (ServioColors.available, const Color(0xFFF0FDF4), l10n.badgeAvailable),
      TableStatus.occupied => (ServioColors.occupied, const Color(0xFFFEF2F2), l10n.badgeOccupied),
      TableStatus.reserved => (ServioColors.reserved, const Color(0xFFFEFCE8), l10n.badgeReserved),
    };
    final reservation = table.upcomingReservation;
    final total = table.currentOrderTotal;
    final mine = table.assignedWaiterId != null && table.assignedWaiterId == me;
    final locked = me != null && !table.isServableBy(me!);
    final owner = table.assignedWaiterId == null ? null : (mine ? l10n.yourTable : table.assignedWaiterName);

    return Opacity(
      opacity: locked ? 0.5 : 1,
      child: Material(
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
                    Expanded(
                      child: Text(
                        l10n.table,
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
                _info(Icons.people_outline, l10n.maxSeats(table.capacity)),
                if (table.currentGuestCount != null)
                  _info(Icons.people, l10n.nowSeated(table.currentGuestCount!), bold: true)
                else if (reservation != null)
                  _info(
                    Icons.schedule,
                    l10n.reservationAt(Formatters.time(reservation.startTime), l10n.guestCount(reservation.partySize)),
                    bold: true,
                  ),
                Text(
                  owner == null ? table.areaName : '${table.areaName} · $owner',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: mine ? ServioColors.primary : ServioColors.textMuted,
                    fontSize: 12,
                    fontWeight: mine ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (total != null) ...[
                  const Divider(height: 12),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.total, style: const TextStyle(fontSize: 12))),
                      Text(
                        Formatters.money(total, currency),
                        style: const TextStyle(color: ServioColors.primary, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    locked ? Icons.lock_outline : Icons.chevron_right,
                    color: locked ? ServioColors.textMuted : ServioColors.primary,
                  ),
                ),
              ],
            ),
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
      title: Text(l10n.tableNumber(widget.table.number)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (reservation != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: ServioColors.warningLight, borderRadius: BorderRadius.circular(10)),
              child: Text(
                l10n.reservedFor(
                  reservation.guestName,
                  Formatters.time(reservation.startTime),
                  l10n.guestCount(reservation.partySize),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(l10n.howManyGuests),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: l10n.fewerGuests,
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
                tooltip: l10n.moreGuests,
                onPressed: _guests < widget.table.capacity ? () => setState(() => _guests++) : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Text(l10n.tableSeats(widget.table.capacity), style: const TextStyle(color: ServioColors.textMuted)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.back)),
        FilledButton(onPressed: () => Navigator.pop(context, _guests), child: Text(l10n.startOrder)),
      ],
    );
  }
}
