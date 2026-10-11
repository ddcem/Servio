import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/admin_page.dart';
import 'table_status_badge.dart';

/// The shift plan: one column per active waiter plus "Unassigned". Tables are dragged between columns
/// (or moved with their menu); a waiter can only take orders at their own and unassigned tables.
class TableAssignmentsScreen extends StatefulWidget {
  const TableAssignmentsScreen({super.key});

  @override
  State<TableAssignmentsScreen> createState() => _TableAssignmentsScreenState();
}

class _TableAssignmentsScreenState extends State<TableAssignmentsScreen> {
  static const _palette = [
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF9333EA),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
    Color(0xFFDB2777),
    Color(0xFF65A30D),
    Color(0xFFCA8A04),
  ];

  late final _tables = context.read<RestaurantTableProvider>();
  late final StreamSubscription<String> _changes;

  List<RestaurantTable>? _items;
  List<User> _waiters = [];
  List<TableArea> _areas = [];
  int? _areaId;
  String _currency = '';
  Object? _error;

  @override
  void initState() {
    super.initState();
    _changes = context.read<RealtimeService>().whereEvent({RealtimeEvents.ordersChanged}).listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final users = context.read<UserProvider>().getAll(filter: {'IsActive': true});
      final areas = context.read<TableAreaProvider>().getAll();
      final settings = context.read<SettingsProvider>().get();
      final tables = await _tables.getAll(filter: {'IsActive': true});
      final waiters = (await users).where((u) => u.role == Roles.waiter).toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
      final loadedAreas = await areas;
      final currency = (await settings).currencySymbol;
      if (!mounted) return;
      setState(() {
        _items = tables;
        _waiters = waiters;
        _areas = loadedAreas;
        _currency = currency;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Color _colorOf(int? waiterId) {
    if (waiterId == null) return ServioColors.textMuted;
    final index = _waiters.indexWhere((w) => w.id == waiterId);
    return index < 0 ? ServioColors.textMuted : _palette[index % _palette.length];
  }

  String? _nameOf(int? waiterId) => _waiters.where((w) => w.id == waiterId).firstOrNull?.fullName;

  /// Shows the move at once and saves it; the board is restored if the server refuses.
  Future<void> _assign(List<RestaurantTable> tables, int? waiterId) async {
    final moving = tables.where((t) => t.assignedWaiterId != waiterId).toList();
    if (moving.isEmpty) return;
    final before = _items!;
    final name = _nameOf(waiterId);
    setState(() {
      final ids = {for (final t in moving) t.id};
      _items = [for (final t in before) ids.contains(t.id) ? t.withWaiter(waiterId, name) : t];
    });
    try {
      await _tables.assign({for (final t in moving) t.id: waiterId});
      if (!mounted) return;
      if (waiterId == null && moving.length == 1) {
        showSuccess(context, l10n.assignmentFreed(moving.single.number));
      } else if (moving.length == 1) {
        showSuccess(context, l10n.assignmentMoved(moving.single.number, name!));
      } else {
        showSuccess(context, l10n.tablesMoved(l10n.tableCount(moving.length), name ?? l10n.unassigned));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = before);
      showError(context, e);
    }
  }

  Future<void> _clearAll() async {
    final assigned = _items!.where((t) => t.assignedWaiterId != null).toList();
    if (assigned.isEmpty) return;
    final confirmed = await confirmAction(
      context,
      title: l10n.clearAllQuestion,
      message: l10n.clearAllMessage,
      confirmLabel: l10n.clearAllAssignments,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _assign(assigned, null);
    if (mounted) showSuccess(context, l10n.planCleared);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      body: AdminPage(
        title: l10n.tableAssignments,
        subtitle: l10n.tableAssignmentsSubtitle,
        backTooltip: l10n.back,
        actions: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: ServioColors.danger),
            onPressed: items == null || items.every((t) => t.assignedWaiterId == null) ? null : _clearAll,
            icon: const Icon(Icons.layers_clear_outlined),
            label: Text(l10n.clearAllAssignments),
          ),
        ],
        child: _error != null && items == null
            ? ErrorView(error: _error!, onRetry: _load)
            : items == null
            ? const LoadingView()
            : _buildBoard(items),
      ),
    );
  }

  Widget _buildBoard(List<RestaurantTable> items) {
    final visible = items.where((t) => _areaId == null || t.areaId == _areaId).toList();
    List<RestaurantTable> tablesOf(int? waiterId) => visible.where((t) => t.assignedWaiterId == waiterId).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final area in [null, ..._areas])
                      ChoiceChip(
                        label: Text(area?.name ?? l10n.allAreas),
                        selected: _areaId == area?.id,
                        onSelected: (_) => setState(() => _areaId = area?.id),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.info_outline, size: 18, color: ServioColors.textMuted),
              const SizedBox(width: 6),
              Text(l10n.openOrderMovesHint, style: const TextStyle(color: ServioColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          if (_waiters.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(l10n.noActiveWaiters, style: const TextStyle(color: ServioColors.warning)),
            ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Column(
                  title: l10n.unassigned,
                  subtitle: l10n.unassignedHint,
                  color: ServioColors.textMuted,
                  tables: tablesOf(null),
                  onDrop: (table) => _assign([table], null),
                  card: (table) => _card(table),
                ),
                for (final waiter in _waiters)
                  _Column(
                    title: waiter.fullName,
                    initials: waiter.initials,
                    color: _colorOf(waiter.id),
                    tables: tablesOf(waiter.id),
                    onDrop: (table) => _assign([table], waiter.id),
                    card: (table) => _card(table),
                    menu: [
                      for (final area in _areas)
                        PopupMenuItem(
                          onTap: () => _assign(items.where((t) => t.areaId == area.id).toList(), waiter.id),
                          child: ListTile(
                            leading: const Icon(Icons.add_location_alt_outlined),
                            title: Text(l10n.addAllOfArea(area.name)),
                          ),
                        ),
                      PopupMenuItem(
                        onTap: () => _assign(items.where((t) => t.assignedWaiterId == waiter.id).toList(), null),
                        child: ListTile(leading: const Icon(Icons.remove_circle_outline), title: Text(l10n.unassignAll)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(RestaurantTable table) {
    final card = _TableCard(table: table, currency: _currency, color: _colorOf(table.assignedWaiterId));
    final menu = PopupMenuButton<int?>(
      tooltip: l10n.moveTo,
      icon: const Icon(Icons.more_vert, size: 20),
      onSelected: (waiterId) => _assign([table], waiterId == 0 ? null : waiterId),
      itemBuilder: (_) => [
        if (table.assignedWaiterId != null) PopupMenuItem(value: 0, child: Text(l10n.unassigned)),
        for (final waiter in _waiters)
          if (waiter.id != table.assignedWaiterId)
            PopupMenuItem(
              value: waiter.id,
              child: Row(
                children: [
                  CircleAvatar(radius: 6, backgroundColor: _colorOf(waiter.id)),
                  const SizedBox(width: 10),
                  Text(waiter.fullName),
                ],
              ),
            ),
      ],
    );

    return Draggable<RestaurantTable>(
      data: table,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(width: 260, child: Opacity(opacity: 0.9, child: card)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: card),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Stack(
          children: [
            card,
            Positioned(top: 4, right: 4, child: menu),
          ],
        ),
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.title,
    required this.color,
    required this.tables,
    required this.onDrop,
    required this.card,
    this.subtitle,
    this.initials,
    this.menu,
  });

  final String title;
  final String? subtitle;
  final String? initials;
  final Color color;
  final List<RestaurantTable> tables;
  final ValueChanged<RestaurantTable> onDrop;
  final Widget Function(RestaurantTable) card;
  final List<PopupMenuEntry<void>>? menu;

  @override
  Widget build(BuildContext context) {
    final seats = tables.fold(0, (sum, t) => sum + t.capacity);
    return DragTarget<RestaurantTable>(
      onWillAcceptWithDetails: (details) => !tables.any((t) => t.id == details.data.id),
      onAcceptWithDetails: (details) => onDrop(details.data),
      builder: (context, candidates, _) {
        final hovering = candidates.isNotEmpty;
        return Container(
          width: 280,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: hovering ? color.withValues(alpha: 0.08) : ServioColors.surfaceMuted,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hovering ? color : ServioColors.border, width: hovering ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: color, width: 4)),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: initials == null
                          ? Icon(Icons.groups_outlined, color: color, size: 20)
                          : Text(
                              initials!,
                              style: TextStyle(color: color, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            subtitle ?? l10n.tablesAndSeats(l10n.tableCount(tables.length), l10n.seatCount(seats)),
                            style: const TextStyle(color: ServioColors.textMuted, fontSize: 12),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    if (menu != null)
                      PopupMenuButton<void>(tooltip: l10n.columnMenu, itemBuilder: (_) => menu!)
                    else
                      const SizedBox(width: 12),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: tables.isEmpty
                    ? Center(
                        child: Text(l10n.dropTablesHere, style: const TextStyle(color: ServioColors.textMuted)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(10),
                        itemCount: tables.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (_, index) => card(tables[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.currency, required this.color});

  final RestaurantTable table;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 10, 40, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border(left: BorderSide(color: color, width: 4)),
      boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.tableNumber(table.number), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            TableStatusBadge(table.status),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${table.areaName} · ${l10n.seatCount(table.capacity)}',
          style: const TextStyle(color: ServioColors.textMuted, fontSize: 13),
        ),
        if (table.currentOrderTotal != null)
          Text(
            l10n.billAndGuests(
              Formatters.money(table.currentOrderTotal!, currency),
              l10n.guestCount(table.currentGuestCount ?? 0),
            ),
            style: const TextStyle(color: ServioColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
      ],
    ),
  );
}
