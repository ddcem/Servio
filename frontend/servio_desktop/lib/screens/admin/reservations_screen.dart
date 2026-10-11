import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/action_icon.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/search_field.dart';
import 'forms/reservation_form.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  late final ReservationProvider _reservations = context.read<ReservationProvider>();
  late final StreamSubscription<String> _changes;

  PagedResult<Reservation>? _result;
  Object? _error;
  int _page = 1;
  String _search = '';
  ReservationStatus? _status;
  DateTimeRange? _range;

  @override
  void initState() {
    super.initState();
    _changes = context.read<RealtimeService>().whereEvent({RealtimeEvents.reservationsChanged}).listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final result = await _reservations.getPage(
        page: _page,
        filter: {
          'FTS': _search,
          'Status': _status == null ? null : enumToApi(_status!),
          'From': _range?.start.toUtc().toIso8601String(),
          'To': _range?.end.add(const Duration(days: 1)).toUtc().toIso8601String(),
        },
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

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 180)),
      initialDateRange: _range,
      helpText: l10n.reservationsBetween,
    );
    if (range != null) _filter(() => _range = range);
  }

  Future<void> _openForm([Reservation? reservation]) async {
    if (await showReservationForm(context, reservation: reservation) == true) {
      if (reservation == null) setState(() => _page = 1);
      await _load();
    }
  }

  Future<void> _run(Future<Reservation> Function() action, String Function(Reservation) message) async {
    try {
      final reservation = await action();
      if (!mounted) return;
      showSuccess(context, message(reservation));
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _cancel(Reservation r) async {
    final reason = await askForReason(
      context,
      title: l10n.cancelReservation,
      message: r.guestEmail == null
          ? l10n.cancelReservationMessage(r.guestName, Formatters.dateTime(r.startTime))
          : l10n.cancelReservationEmailMessage(r.guestName, Formatters.dateTime(r.startTime)),
      confirmLabel: l10n.cancelReservation,
    );
    if (reason == null) return;
    await _run(() => _reservations.cancel(r.id, reason), (x) => l10n.reservationCancelledFor(x.guestName));
  }

  Future<void> _showDetails(Reservation summary) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ReservationDetails(id: summary.id),
    );
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: l10n.reservations,
    subtitle: l10n.reservationsSubtitle,
    actions: [
      FilledButton.icon(onPressed: () => _openForm(), icon: const Icon(Icons.add), label: Text(l10n.newReservationButton)),
    ],
    child: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SearchField(hint: l10n.guestNameOrPhone, onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<ReservationStatus>(
              label: 'Status',
              value: _status,
              items: {for (final s in ReservationStatus.values) s: s.label},
              onChanged: (value) => _filter(() => _status = value),
            ),
            OutlinedButton.icon(
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _range == null ? l10n.anyDate : l10n.dateRange(Formatters.date(_range!.start), Formatters.date(_range!.end)),
              ),
            ),
            if (_range != null)
              IconButton(tooltip: l10n.clearDates, onPressed: () => _filter(() => _range = null), icon: const Icon(Icons.clear)),
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
    if (_result!.items.isEmpty) return EmptyView(icon: Icons.event_outlined, message: l10n.noReservationsMatch);

    final now = DateTime.now();
    return Panel(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          WideTable(
            child: DataTable(
              dataRowMinHeight: 56,
              dataRowMaxHeight: 64,
              showCheckboxColumn: false,
              headingTextStyle: TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
              columns: [
                DataColumn(label: Text(l10n.columnGuest)),
                DataColumn(label: Text(l10n.columnWhen)),
                DataColumn(label: Text(l10n.columnTable)),
                DataColumn(label: Text(l10n.columnGuests), numeric: true),
                DataColumn(label: Text(l10n.columnStatus)),
                DataColumn(label: Text(l10n.columnActions)),
              ],
              rows: [
                for (final r in _result!.items)
                  DataRow(
                    onSelectChanged: (_) => _showDetails(r),
                    cells: [
                      DataCell(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.guestName, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(r.guestPhone, style: const TextStyle(color: ServioColors.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      DataCell(Text(l10n.timeRange(Formatters.dateTime(r.startTime), Formatters.time(r.endTime)))),
                      DataCell(Text(l10n.tableNumber(r.tableNumber))),
                      DataCell(Text('${r.partySize}')),
                      DataCell(ReservationStatusBadge(r.status)),
                      DataCell(
                        Row(
                          children: [
                            if (r.status == ReservationStatus.pending)
                              ActionIcon(
                                icon: Icons.check_circle_outline,
                                tooltip: l10n.confirmEmailsGuest,
                                color: ServioColors.success,
                                onPressed: () =>
                                    _run(() => _reservations.confirm(r.id), (x) => l10n.reservationConfirmedFor(x.guestName)),
                              ),
                            if (r.status == ReservationStatus.confirmed) ...[
                              ActionIcon(
                                icon: Icons.event_seat_outlined,
                                tooltip: l10n.guestsArrived,
                                color: ServioColors.success,
                                disabledReason: now.isBefore(r.startTime.subtract(const Duration(minutes: 30)))
                                    ? l10n.arrivedTooEarly
                                    : null,
                                onPressed: () => _run(() => _reservations.complete(r.id), (x) => l10n.guestArrived(x.guestName)),
                              ),
                              ActionIcon(
                                icon: Icons.person_off_outlined,
                                tooltip: l10n.noShow,
                                color: ServioColors.warning,
                                disabledReason: now.isBefore(r.startTime.add(const Duration(minutes: 15)))
                                    ? l10n.noShowTooEarly
                                    : null,
                                onPressed: () =>
                                    _run(() => _reservations.markNoShow(r.id), (x) => l10n.markedNoShow(x.guestName)),
                              ),
                            ],
                            if (r.isActive) ...[
                              ActionIcon(
                                icon: Icons.edit_outlined,
                                tooltip: l10n.edit,
                                color: ServioColors.primary,
                                onPressed: () => _openForm(r),
                              ),
                              ActionIcon(
                                icon: Icons.cancel_outlined,
                                tooltip: l10n.cancel,
                                color: ServioColors.danger,
                                onPressed: () => _cancel(r),
                              ),
                            ],
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

class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge(this.status, {super.key});

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
    ReservationStatus.pending => StatusBadge(status.label, color: ServioColors.warning, background: ServioColors.warningLight),
    ReservationStatus.confirmed => StatusBadge(status.label, color: ServioColors.primaryDark, background: ServioColors.infoLight),
    ReservationStatus.completed => StatusBadge(status.label, color: ServioColors.success, background: ServioColors.successLight),
    _ => StatusBadge(status.label, color: ServioColors.danger, background: ServioColors.dangerLight),
  };
}

/// Master–detail: the reservation with its full audit trail.
class _ReservationDetails extends StatelessWidget {
  const _ReservationDetails({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: FutureBuilder<Reservation>(
        future: context.read<ReservationProvider>().getById(id),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorView(error: snapshot.error!);
          if (!snapshot.hasData) return const SizedBox(height: 200, child: LoadingView());
          final r = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(r.guestName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    ReservationStatusBadge(r.status),
                    IconButton(tooltip: l10n.close, onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 12),
                _row(Icons.event, l10n.timeRange(Formatters.dateTime(r.startTime), Formatters.time(r.endTime))),
                _row(Icons.table_restaurant_outlined, l10n.tableAndGuests(r.tableNumber, l10n.guestCount(r.partySize))),
                _row(Icons.phone_outlined, r.guestPhone),
                if (r.guestEmail != null) _row(Icons.email_outlined, r.guestEmail!),
                if (r.note != null) _row(Icons.notes, r.note!),
                _row(Icons.person_outline, l10n.createdByOn(r.createdByName, Formatters.dateTime(r.createdAt))),
                const Divider(height: 32),
                Text(l10n.history, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                for (final h in r.history)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history, size: 20),
                    title: Text(
                      h.fromStatus == null
                          ? l10n.createdAs(_statusLabel(h.toStatus))
                          : l10n.statusChange(_statusLabel(h.fromStatus!), _statusLabel(h.toStatus)),
                    ),
                    subtitle: Text(
                      '${h.changedByName} · ${Formatters.dateTime(h.changedAt)}${h.reason == null ? '' : '\n${l10n.reasonText(h.reason!)}'}',
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 18, color: ServioColors.textMuted),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

/// A status as the API names it ("NoShow") in the user's language.
String _statusLabel(String apiName) =>
    ReservationStatus.values.where((s) => enumToApi(s) == apiName).firstOrNull?.label ?? apiName;
