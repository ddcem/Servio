import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/action_icon.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';
import 'forms/table_form.dart';
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
      title: 'Delete table ${table.number}?',
      message: 'The table is removed permanently.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      await _tables.delete(table.id);
      if (!mounted) return;
      showSuccess(context, 'Table ${table.number} was deleted.');
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: 'Tables',
    subtitle: 'Seating plan with live status',
    actions: [
      Tooltip(
        message: _areas.isEmpty ? 'Add a table area first (Reference Data → Table areas).' : '',
        child: FilledButton.icon(
          onPressed: _areas.isEmpty ? null : () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('Add Table'),
        ),
      ),
    ],
    child: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            SearchField(hint: 'Table number', width: 180, onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<int>(
              label: 'Area',
              value: _areaId,
              items: {for (final a in _areas) a.id: a.name},
              onChanged: (value) => _filter(() => _areaId = value),
            ),
            FilterDropdown<TableStatus>(
              label: 'Status',
              value: _status,
              items: const {
                TableStatus.available: 'Available',
                TableStatus.occupied: 'Occupied',
                TableStatus.reserved: 'Reserved',
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
    if (_result == null) return const LoadingView();
    if (_result!.items.isEmpty) {
      return const EmptyView(icon: Icons.table_restaurant_outlined, message: 'No tables match the filters.');
    }

    return Panel(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          WideTable(
            child: DataTable(
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
              columns: const [
                DataColumn(label: Text('TABLE')),
                DataColumn(label: Text('AREA')),
                DataColumn(label: Text('SEATS'), numeric: true),
                DataColumn(label: Text('STATUS')),
                DataColumn(label: Text('CURRENT BILL'), numeric: true),
                DataColumn(label: Text('NEXT RESERVATION')),
                DataColumn(label: Text('ACTIONS')),
              ],
              rows: [
                for (final table in _result!.items)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          'Table ${table.number}${table.isActive ? '' : ' (not in use)'}',
                          style: TextStyle(fontWeight: FontWeight.w600, color: table.isActive ? null : ServioColors.textMuted),
                        ),
                      ),
                      DataCell(Text(table.areaName)),
                      DataCell(Text('${table.capacity}')),
                      DataCell(TableStatusBadge(table.status)),
                      DataCell(
                        Text(
                          table.currentOrderTotal == null
                              ? '–'
                              : '${Formatters.money(table.currentOrderTotal!, _currency)} · ${table.currentGuestCount} guests',
                        ),
                      ),
                      DataCell(
                        Text(
                          table.upcomingReservation == null
                              ? '–'
                              : '${Formatters.dateTime(table.upcomingReservation!.startTime)} · ${table.upcomingReservation!.guestName}',
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            ActionIcon(
                              icon: Icons.edit_outlined,
                              tooltip: 'Edit',
                              color: ServioColors.primary,
                              onPressed: () => _openForm(table),
                            ),
                            ActionIcon(
                              icon: Icons.delete_outline,
                              tooltip: 'Delete table',
                              color: ServioColors.danger,
                              disabledReason: table.hasHistory
                                  ? 'The table has orders or reservations in its history. Mark it as not in use instead.'
                                  : null,
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
