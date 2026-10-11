import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

/// Kitchen or bar display. Staff move tickets from New to Preparing to Ready; once ready, a ticket
/// leaves the screen and the waiter is notified. The admin opens the same screen in view-only mode.
class StationDisplayScreen extends StatefulWidget {
  const StationDisplayScreen({super.key, required this.station, this.viewOnly = false});

  final String station;
  final bool viewOnly;

  @override
  State<StationDisplayScreen> createState() => _StationDisplayScreenState();
}

class _StationDisplayScreenState extends State<StationDisplayScreen> {
  late final OrderTicketProvider _tickets = context.read<OrderTicketProvider>();
  late final StreamSubscription<String> _changes;
  late final Timer _clock;

  List<OrderTicket>? _items;
  StationSummary? _summary;
  Object? _error;
  int? _stationId;
  final Set<int> _busy = {};

  bool get _isKitchen => widget.station == Stations.kitchen;
  Color get _color => _isKitchen ? ServioColors.kitchen : ServioColors.bar;
  Color get _colorDark => _isKitchen ? ServioColors.kitchenDark : ServioColors.barDark;

  @override
  void initState() {
    super.initState();
    _changes = context.read<RealtimeService>().whereEvent({RealtimeEvents.ticketsChanged}).listen((_) => _load());
    // Waiting times on the cards are recalculated every 30 seconds.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _changes.cancel();
    _clock.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _stationId ??= (await context.read<PreparationStationProvider>().getAll()).firstWhere((x) => x.name == widget.station).id;
      final results = await Future.wait([
        _tickets.getPage(filter: {'StationId': _stationId, 'ActiveOnly': true}, pageSize: 100),
        if (widget.viewOnly) _tickets.getStationSummaries(),
      ]);
      if (!mounted) return;
      setState(() {
        _items = (results[0] as PagedResult<OrderTicket>).items;
        if (widget.viewOnly) {
          _summary = (results[1] as List<StationSummary>).firstWhere((x) => x.stationId == _stationId);
        }
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _advance(OrderTicket ticket) async {
    setState(() => _busy.add(ticket.id));
    try {
      if (ticket.status == TicketStatus.newTicket) {
        await _tickets.start(ticket.id);
        if (mounted) showSuccess(context, l10n.ticketBeingPrepared(ticket.ticketNumber, ticket.tableNumber));
      } else {
        await _tickets.markReady(ticket.id);
        if (mounted) {
          showSuccess(context, l10n.ticketReadyNotified(ticket.ticketNumber, ticket.waiterName));
        }
      }
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy.remove(ticket.id));
    }
  }

  @override
  Widget build(BuildContext _) {
    final user = context.watch<AuthProvider>().user;
    final count = _items?.length ?? 0;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [_color, _colorDark])),
            child: Row(
              children: [
                if (widget.viewOnly) ...[
                  IconButton(
                    tooltip: l10n.back,
                    color: Colors.white,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                ],
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(_isKitchen ? Icons.restaurant : Icons.wine_bar_outlined, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isKitchen ? l10n.kitchenDisplay : l10n.barDisplay,
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      Text(l10n.activeOrdersCount(count), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
                if (widget.viewOnly)
                  _HeaderChip(icon: Icons.visibility_outlined, label: l10n.viewOnly)
                else if (user != null)
                  _UserMenu(user: user),
              ],
            ),
          ),
          if (_summary != null) _SummaryBar(summary: _summary!, color: _color),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items == null) return ErrorView(error: _error!, onRetry: _load);
    if (_items == null) return const LoadingView();
    if (_items!.isEmpty) {
      return EmptyView(
        icon: _isKitchen ? Icons.restaurant : Icons.wine_bar_outlined,
        message: _isKitchen ? l10n.noPendingFood : l10n.noPendingDrinks,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          for (final ticket in _items!)
            _TicketCard(
              ticket: ticket,
              isKitchen: _isKitchen,
              viewOnly: widget.viewOnly,
              busy: _busy.contains(ticket.id),
              onAdvance: () => _advance(ticket),
            ),
        ],
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.isKitchen,
    required this.viewOnly,
    required this.busy,
    required this.onAdvance,
  });

  final OrderTicket ticket;
  final bool isKitchen;
  final bool viewOnly;
  final bool busy;
  final VoidCallback onAdvance;

  bool get _isNew => ticket.status == TicketStatus.newTicket;

  Color _elapsedColor(Duration waiting) => waiting.inMinutes < 10
      ? ServioColors.success
      : waiting.inMinutes < 15
      ? ServioColors.warning
      : ServioColors.danger;

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiClient>();
    final images = context.read<MenuItemProvider>();
    final waiting = DateTime.now().difference(ticket.createdAt);
    final accent = _isNew ? ServioColors.primary : ServioColors.reserved;

    return SizedBox(
      width: 340,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border(left: BorderSide(color: accent, width: 6)),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.ticketTitle(ticket.ticketNumber),
                        style: const TextStyle(color: ServioColors.textMuted, fontSize: 15),
                      ),
                      Text(
                        l10n.tableNumber(ticket.tableNumber),
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      Text(ticket.waiterName, style: const TextStyle(color: ServioColors.textMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: ServioColors.textMuted),
                        const SizedBox(width: 4),
                        Text(Formatters.time(ticket.createdAt), style: const TextStyle(color: ServioColors.textMuted)),
                      ],
                    ),
                    Text(
                      Formatters.elapsed(waiting),
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _elapsedColor(waiting)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final item in ticket.items)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    AuthImage(url: images.imageUrl(item.menuItemId), headers: api.authHeaders, hasImage: true, size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.menuItemName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          if (item.note != null)
                            Text(
                              item.note!,
                              style: const TextStyle(color: ServioColors.danger, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                    Text('x${item.quantity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (!viewOnly)
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _isNew ? ServioColors.reserved : ServioColors.available,
                  minimumSize: const Size(0, 52),
                ),
                onPressed: busy ? null : onAdvance,
                icon: busy
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(_isNew ? Icons.schedule : Icons.check_circle_outline),
                label: Text(_isNew ? l10n.startPreparing : (isKitchen ? l10n.markAsReady : l10n.completeOrder)),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _isNew ? ServioColors.infoLight : ServioColors.warningLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket.status.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: _isNew ? ServioColors.primaryDark : ServioColors.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The admin's overview of the station's workload.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.summary, required this.color});

  final StationSummary summary;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final oldest = summary.oldestWaitingSince;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Wrap(
        spacing: 40,
        runSpacing: 8,
        children: [
          _metric(l10n.summaryNew, '${summary.newCount}'),
          _metric(l10n.summaryPreparing, '${summary.preparingCount}'),
          _metric(l10n.longestWait, oldest == null ? '–' : Formatters.elapsed(DateTime.now().difference(oldest))),
          _metric(
            l10n.avgTimeToReadyToday,
            summary.averageMinutesToReadyToday == null
                ? '–'
                : l10n.minutesValue(Formatters.decimal(summary.averageMinutesToReadyToday!)),
          ),
          _metric(l10n.completedToday, '${summary.completedToday}'),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: ServioColors.textMuted, fontSize: 12)),
      Text(
        value,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    ],
  );
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _UserMenu extends StatelessWidget {
  const _UserMenu({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => PopupMenuButton<void>(
    tooltip: l10n.account,
    offset: const Offset(0, 56),
    itemBuilder: (_) => [
      PopupMenuItem(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.roleStaff(Roles.label(user.role)), style: const TextStyle(color: ServioColors.textMuted)),
            Text(
              user.fullName,
              style: const TextStyle(color: ServioColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        onTap: () => showDialog<void>(context: context, builder: (_) => const _SettingsDialog()),
        child: ListTile(
          leading: const Icon(Icons.settings_outlined),
          title: Text(l10n.settings),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      PopupMenuItem(
        onTap: () => context.read<AuthProvider>().logout(),
        child: ListTile(leading: const Icon(Icons.logout), title: Text(l10n.logout), contentPadding: EdgeInsets.zero),
      ),
    ],
    child: _HeaderChip(icon: Icons.person_outline, label: user.username),
  );
}

/// Kitchen and bar staff choose their language here; the display switches immediately.
class _SettingsDialog extends StatelessWidget {
  const _SettingsDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(l10n.settings),
    content: SizedBox(
      width: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.bold)),
          const LanguagePicker(),
          Text(l10n.languageHint, style: const TextStyle(color: ServioColors.textMuted)),
        ],
      ),
    ),
    actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close))],
  );
}
