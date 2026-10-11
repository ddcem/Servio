import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/action_icon.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';
import 'forms/table_form.dart';
import 'table_assignments_screen.dart';
import 'table_status_badge.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  late final RestaurantTableProvider _tables = context.read<RestaurantTableProvider>();
  late final StreamSubscription<String> _changes;

  PagedResult<RestaurantTable>? _result;
  Object? _error;
  List<TableArea> _areas = [];
  String _currency = '';
  int _page = 1;
  String _search = '';
  int? _areaId;
  TableStatus? _status;

  @override
  void initState() {
    super.initState();
    _changes = context
        .read<RealtimeService>()
        .whereEvent({RealtimeEvents.ordersChanged, RealtimeEvents.reservationsChanged})
        .listen((_) => _load());
    _loadReferenceData();
    _load();
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }

  Future<void> _loadReferenceData() async {
    final results = await Future.wait([context.read<TableAreaProvider>().getAll(), context.read<SettingsProvider>().get()]);
    if (!mounted) return;
    setState(() {
      _areas = results[0] as List<TableArea>;
      _currency = (results[1] as RestaurantSettings).currencySymbol;
    });
  }

  Future<void> _load() async {
    try {
      final result = await _tables.getPage(
        page: _page,
        filter: {'FTS': _search, 'AreaId': _areaId, 'Status': _status == null ? null : enumToApi(_status!)},
      );
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

  void _filter(VoidCallback change) {
    setState(() {
      change();
      _page = 1;
    });
    _load();
  }

  Future<void> _openForm([RestaurantTable? table]) async {
    if (await showTableForm(context, table: table) == true) {
      await _loadReferenceData();
      await _load();
    }
  }

  Future<void> _delete(RestaurantTable table) async {
    final confirmed = await confirmAction(
      context,
      title: l10n.deleteTableQuestion(table.number),
      message: l10n.tableRemovedPermanently,
      confirmLabel: l10n.delete,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _tables.delete(table.id);
      if (!mounted) return;
      showSuccess(context, l10n.tableDeleted(table.number));
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: l10n.tables,
    subtitle: l10n.tablesSubtitle,
    actions: [
      OutlinedButton.icon(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TableAssignmentsScreen()));
          _load();
        },
        icon: const Icon(Icons.badge_outlined),
        label: Text(l10n.assignWaiters),
      ),
      Tooltip(
        message: _areas.isEmpty ? l10n.addAreaFirst : '',
        child: FilledButton.icon(
          onPressed: _areas.isEmpty ? null : () => _openForm(),
          icon: const Icon(Icons.add),
          label: Text(l10n.addTableButton),
        ),
      ),
    ],
    child: ListView(
      padding: EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SearchField(hint: l10n.tableNumberLabel, width: 180, onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<int>(
              label: l10n.area,
              value: _areaId,
              items: {for (final a in _areas) a.id: a.name},
              onChanged: (value) => _filter(() => _areaId = value),
            ),
            FilterDropdown<TableStatus>(
              label: 'Status',
              value: _status,
              items: {
                TableStatus.available: l10n.available,
                TableStatus.occupied: l10n.occupied,
                TableStatus.reserved: l10n.reserved,
              },
              onChanged: (value) => _filter(() => _status = value),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTable(),
      ],
    ),
  );

  Widget _buildTable() {
    if (_error != null && _result == null) return ErrorView(error: _error!, onRetry: _load);
    if (_result == null) return LoadingView();
    if (_result!.items.isEmpty) {
      return EmptyView(icon: Icons.table_restaurant_outlined, message: l10n.noTablesMatch);
    }

    return Panel(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          WideTable(
            child: DataTable(
              headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
              columns: [
                DataColumn(label: Text(l10n.columnTable)),
                DataColumn(label: Text(l10n.columnArea)),
                DataColumn(label: Text(l10n.columnSeats), numeric: true),
                DataColumn(label: Text(l10n.columnStatus)),
                DataColumn(label: Text(l10n.columnWaiter)),
                DataColumn(label: Text(l10n.columnCurrentBill), numeric: true),
                DataColumn(label: Text(l10n.columnNextReservation)),
                DataColumn(label: Text(l10n.columnActions)),
              ],
              rows: [
                for (final table in _result!.items)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          table.isActive ? l10n.tableNumber(table.number) : l10n.tableNotInUse(table.number),
                          style: TextStyle(fontWeight: FontWeight.w600, color: table.isActive ? null : ServioColors.textMuted),
                        ),
                      ),
                      DataCell(Text(table.areaName)),
                      DataCell(Text('${table.capacity}')),
                      DataCell(TableStatusBadge(table.status)),
                      DataCell(
                        Text(
                          table.assignedWaiterName ?? l10n.unassigned,
                          style: TextStyle(color: table.assignedWaiterName == null ? ServioColors.textMuted : null),
                        ),
                      ),
                      DataCell(
                        Text(
                          table.currentOrderTotal == null
                              ? '–'
                              : l10n.billAndGuests(
                                  Formatters.money(table.currentOrderTotal!, _currency),
                                  l10n.guestCount(table.currentGuestCount ?? 0),
                                ),
                        ),
                      ),
                      DataCell(
                        Text(
                          table.upcomingReservation == null
                              ? '–'
                              : l10n.reservationTimeAndGuest(
                                  Formatters.dateTime(table.upcomingReservation!.startTime),
                                  table.upcomingReservation!.guestName,
                                ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ActionIcon(
                              icon: Icons.edit_outlined,
                              tooltip: l10n.edit,
                              color: ServioColors.primary,
                              onPressed: () => _openForm(table),
                            ),
                            ActionIcon(
                              icon: Icons.delete_outline,
                              tooltip: l10n.deleteTable,
                              color: ServioColors.danger,
                              disabledReason: table.hasHistory ? l10n.tableHasHistory : null,
                              onPressed: () => _delete(table),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Pager(
              page: _page,
              pageCount: _result!.pageCount,
              totalCount: _result!.totalCount,
              onChanged: (page) {
                setState(() => _page = page);
                _load();
              },
            ),
          ),
        ],
      ),
    );
  }
}
