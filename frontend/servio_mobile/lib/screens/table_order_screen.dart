import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import '../widgets/order_card.dart';
import 'menu_screen.dart';
import 'payment_screen.dart';

/// The open order of one table, opened from the table grid.
class TableOrderScreen extends StatefulWidget {
  const TableOrderScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<TableOrderScreen> createState() => _TableOrderScreenState();
}

class _TableOrderScreenState extends State<TableOrderScreen> {
  late final _orders = context.read<OrderProvider>();
  late final StreamSubscription<String> _changes;
  Order? _order;
  Object? _error;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _changes = context
        .read<RealtimeService>()
        .whereEvent({RealtimeEvents.ordersChanged, RealtimeEvents.ticketsChanged})
        .listen((_) => _load());
    _load();
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final order = await _orders.getById(widget.orderId);
      if (!mounted || _leaving) return;
      if (order.status != OrderStatus.open) {
        // Paid or cancelled in the meantime (possibly on another device): the table is free again.
        _leave();
        return;
      }
      setState(() {
        _order = order;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Closes this screen once, and only while it is on top; payment screens close it themselves.
  void _leave() {
    if (_leaving || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
    _leaving = true;
    Navigator.of(context).pop();
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    if (mounted) _load();
  }

  Future<void> _cancel() async {
    final reason = await askForReason(
      context,
      title: 'Cancel order',
      message: 'Only orders that the kitchen and bar have not started can be cancelled. Why is it cancelled?',
      confirmLabel: 'Cancel order',
    );
    if (reason == null || !mounted) return;
    try {
      await _orders.cancel(widget.orderId, reason);
      if (!mounted) return;
      showSuccess(context, 'The order was cancelled.');
      _leave();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    return Scaffold(
      appBar: GradientAppBar(
        title: order == null ? 'Order' : 'Table ${order.tableNumber}',
        subtitle: order == null ? null : '${order.orderNumber} · ${order.waiterName}',
        actions: [
          if (order != null)
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (_) => _cancel(),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'cancel',
                  child: ListTile(
                    leading: Icon(Icons.cancel_outlined, color: ServioColors.danger),
                    title: Text('Cancel order'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _error != null && order == null
          ? ErrorView(error: _error!, onRetry: _load)
          : order == null
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  OrderCard(
                    order: order,
                    onChanged: _load,
                    onAddItems: () => _open(MenuScreen(tableId: order.tableId, tableNumber: order.tableNumber, order: order)),
                    onPayment: () => _open(PaymentScreen(order: order)),
                  ),
                ],
              ),
            ),
    );
  }
}
