import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../../widgets/wide_table.dart';
import '../../widgets/admin_page.dart';
import '../../widgets/form_dialog.dart';
import '../../widgets/search_field.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late final OrderProvider _orders = context.read<OrderProvider>();
  late final StreamSubscription<String> _changes;

  PagedResult<Order>? _result;
  Object? _error;
  int _page = 1;
  String _search = '';
  OrderStatus? _status;
  DateTimeRange? _range;

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
      final result = await _orders.getPage(
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
      lastDate: now,
      initialDateRange: _range,
      helpText: 'Orders opened between',
    );
    if (range != null) _filter(() => _range = range);
  }

  @override
  Widget build(BuildContext _) => AdminPage(
    title: 'Orders & Payments',
    subtitle: 'Every bill with its items, kitchen/bar tickets, payments and refunds',
    child: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SearchField(hint: 'Order number or table', onChanged: (value) => _filter(() => _search = value)),
            FilterDropdown<OrderStatus>(
              label: 'Status',
              value: _status,
              items: const {OrderStatus.open: 'Open', OrderStatus.completed: 'Paid', OrderStatus.cancelled: 'Cancelled'},
              onChanged: (value) => _filter(() => _status = value),
            ),
            OutlinedButton.icon(
              onPressed: _pickRange,
              icon: const Icon(Icons.date_range),
              label: Text(_range == null ? 'Any date' : '${Formatters.date(_range!.start)} – ${Formatters.date(_range!.end)}'),
            ),
            if (_range != null)
              IconButton(tooltip: 'Clear dates', onPressed: () => _filter(() => _range = null), icon: const Icon(Icons.clear)),
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
      return const EmptyView(icon: Icons.receipt_long_outlined, message: 'No orders match the filters.');
    }

    return Panel(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          WideTable(
            child: DataTable(
              showCheckboxColumn: false,
              headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: ServioColors.textMuted),
              columns: const [
                DataColumn(label: Text('ORDER')),
                DataColumn(label: Text('TABLE')),
                DataColumn(label: Text('WAITER')),
                DataColumn(label: Text('OPENED')),
                DataColumn(label: Text('ITEMS'), numeric: true),
                DataColumn(label: Text('TOTAL'), numeric: true),
                DataColumn(label: Text('STATUS')),
              ],
              rows: [
                for (final order in _result!.items)
                  DataRow(
                    onSelectChanged: (_) async {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => OrderDetailsDialog(orderId: order.id),
                      );
                      await _load();
                    },
                    cells: [
                      DataCell(Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('Table ${order.tableNumber}')),
                      DataCell(Text(order.waiterName)),
                      DataCell(Text(Formatters.dateTime(order.openedAt))),
                      DataCell(Text('${order.itemCount}')),
                      DataCell(
                        Text(
                          Formatters.money(order.total, order.currencySymbol),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(OrderStatusBadge(order)),
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

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge(this.order, {super.key});

  final Order order;

  @override
  Widget build(BuildContext context) => switch (order.status) {
    OrderStatus.open => const StatusBadge('Open', color: ServioColors.primaryDark, background: ServioColors.infoLight),
    OrderStatus.completed => const StatusBadge('Paid', color: ServioColors.success, background: ServioColors.successLight),
    OrderStatus.cancelled => const StatusBadge('Cancelled', color: ServioColors.danger, background: ServioColors.dangerLight),
  };
}

/// Master–detail view of one order: lines, tickets, totals, payments and refunds.
class OrderDetailsDialog extends StatefulWidget {
  const OrderDetailsDialog({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailsDialog> createState() => _OrderDetailsDialogState();
}

class _OrderDetailsDialogState extends State<OrderDetailsDialog> {
  Order? _order;
  List<Payment> _payments = [];
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final payments = context.read<PaymentProvider>();
      final results = await Future.wait([
        context.read<OrderProvider>().getById(widget.orderId),
        payments.getPage(filter: {'OrderId': widget.orderId}),
      ]);
      // The list does not include refunds, so each payment's details are loaded.
      final paymentDetails = await Future.wait((results[1] as PagedResult<Payment>).items.map((p) => payments.getById(p.id)));
      if (!mounted) return;
      setState(() {
        _order = results[0] as Order;
        _payments = paymentDetails;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _cancelOrder() async {
    final order = _order!;
    final reason = await askForReason(
      context,
      title: 'Cancel order ${order.orderNumber}',
      message: 'Tickets that were not started are cancelled and the kitchen and bar are notified.',
      confirmLabel: 'Cancel order',
    );
    if (reason == null || !mounted) return;
    try {
      await context.read<OrderProvider>().cancel(order.id, reason);
      if (!mounted) return;
      showSuccess(context, 'Order ${order.orderNumber} for table ${order.tableNumber} was cancelled.');
      await _load();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _refund(Payment payment) async {
    final refunded = await showDialog<bool>(
      context: context,
      builder: (_) => _RefundDialog(payment: payment),
    );
    if (refunded == true) await _load();
  }

  @override
  Widget build(BuildContext _) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 760, maxHeight: MediaQuery.sizeOf(context).height * 0.9),
      child: _error != null
          ? ErrorView(error: _error!, onRetry: _load)
          : _order == null
          ? const SizedBox(height: 240, child: LoadingView())
          : _buildContent(_order!),
    ),
  );

  Widget _buildContent(Order order) {
    final symbol = order.currencySymbol;
    String money(double value) => Formatters.money(value, symbol);
    final inProgress = order.tickets.any(
      (t) => t.status == TicketStatus.preparing || t.status == TicketStatus.ready || t.status == TicketStatus.served,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ${order.orderNumber}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(
                      'Table ${order.tableNumber} · ${order.guestCount} guests · ${order.waiterName} · opened ${Formatters.dateTime(order.openedAt)}',
                      style: const TextStyle(color: ServioColors.textMuted),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(order),
              IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          if (order.cancellationReason != null) ...[
            const SizedBox(height: 8),
            Text('Cancelled: ${order.cancellationReason}', style: const TextStyle(color: ServioColors.danger)),
          ],
          const SizedBox(height: 20),
          const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          for (final item in order.items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${item.menuItemName} × ${item.quantity}',
                style: TextStyle(decoration: item.ticketStatus == TicketStatus.cancelled ? TextDecoration.lineThrough : null),
              ),
              subtitle: Text(
                ['${money(item.unitPrice)} each', item.ticketStatus.label, if (item.note != null) item.note!].join(' · '),
              ),
              trailing: Text(money(item.lineTotal)),
            ),
          const Divider(),
          _totalRow('Subtotal', money(order.subtotal)),
          _totalRow('Tax (${order.taxRate.toStringAsFixed(order.taxRate % 1 == 0 ? 0 : 2)}%)', money(order.taxAmount)),
          _totalRow('Total', money(order.total), bold: true),
          const SizedBox(height: 16),
          const Text('Kitchen and bar tickets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in order.tickets) Chip(label: Text('${t.ticketNumber} · ${t.stationName} · ${t.status.label}')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          if (_payments.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No payments yet.')),
          for (final p in _payments)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p.paymentMethod} · ${money(p.amount)}${p.tipAmount > 0 ? ' (incl. ${money(p.tipAmount)} tip)' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(p.status.label),
                        const SizedBox(width: 12),
                        Tooltip(
                          message: p.canRefund
                              ? 'Refund up to ${money(p.refundableAmount)}'
                              : 'Nothing left to refund on this payment.',
                          child: OutlinedButton.icon(
                            onPressed: p.canRefund ? () => _refund(p) : null,
                            icon: const Icon(Icons.undo),
                            label: const Text('Refund'),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${p.processedByName} · ${Formatters.dateTime(p.completedAt ?? p.createdAt)}'
                      '${p.cashReceived == null ? '' : ' · received ${money(p.cashReceived!)}, change ${money(p.changeGiven!)}'}',
                      style: const TextStyle(color: ServioColors.textMuted, fontSize: 12),
                    ),
                    for (final r in p.refunds)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '↩ ${money(r.amount)} refunded by ${r.refundedByName} on ${Formatters.dateTime(r.createdAt)} – ${r.reason}',
                          style: const TextStyle(color: ServioColors.danger, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (order.status == OrderStatus.open) ...[
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Tooltip(
                message: inProgress ? 'Items are already being prepared or were served, so the order has to be paid.' : '',
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: ServioColors.danger),
                  onPressed: inProgress ? null : _cancelOrder,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel order'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null, fontSize: bold ? 16 : null),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null, fontSize: bold ? 16 : null),
        ),
      ],
    ),
  );
}

/// Refund through the original payment method; PayPal refunds go through PayPal.
class _RefundDialog extends StatefulWidget {
  const _RefundDialog({required this.payment});

  final Payment payment;

  @override
  State<_RefundDialog> createState() => _RefundDialogState();
}

class _RefundDialogState extends State<_RefundDialog> {
  final _formKey = GlobalKey<FormState>();
  final _server = ServerErrors();
  late final _amount = TextEditingController(text: widget.payment.refundableAmount.toStringAsFixed(2));
  final _reason = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    final p = widget.payment;
    final refundable = Formatters.money(p.refundableAmount, p.currencySymbol);
    return FormDialog(
      title: 'Refund payment',
      formKey: _formKey,
      serverErrors: _server,
      saveLabel: 'Refund',
      width: 460,
      onSave: () async {
        final ok = await confirmAction(
          context,
          title: 'Refund ${Formatters.money(Validators.parseDecimal(_amount.text), p.currencySymbol)}?',
          message: p.paymentMethod == 'PayPal'
              ? 'The money is returned to the guest\'s PayPal account. This cannot be undone.'
              : 'Give the cash back to the guest. This cannot be undone.',
          confirmLabel: 'Refund',
          destructive: true,
        );
        if (!ok || !mounted) return;
        final result = await context.read<PaymentProvider>().refund(
          p.id,
          Validators.parseDecimal(_amount.text),
          _reason.text.trim(),
        );
        if (!mounted) return;
        Navigator.pop(context, true);
        showSuccess(
          context,
          'Refund of ${Formatters.money(result.refundedAmount - p.refundedAmount, p.currencySymbol)} for order ${p.orderNumber} was completed.',
        );
      },
      children: [
        Text(
          '${p.paymentMethod} payment of ${Formatters.money(p.capturedAmount ?? p.amount, p.currencySymbol)}. '
          'Up to $refundable can still be refunded.',
        ),
        TextFormField(
          controller: _amount,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Amount', helperText: 'At most $refundable'),
          validator: (value) =>
              _server['Amount'] ?? Validators.decimal(value, 'Refund amount', min: 0.01, max: p.refundableAmount),
        ),
        TextFormField(
          controller: _reason,
          maxLines: 2,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Reason', hintText: 'e.g. Steak was overcooked'),
          validator: (value) => _server['Reason'] ?? Validators.length(value, 'Reason', min: 3, max: 500),
        ),
      ],
    );
  }
}
