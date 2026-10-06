import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import '../widgets/order_card.dart';
import 'menu_screen.dart';
import 'payment_screen.dart';

/// Every open order of the logged-in waiter, kept up to date as the kitchen and bar work.
class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  late final StreamSubscription<String> _changes;
  List<Order>? _orders;
  Object? _error;

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
      final orders = await context.read<OrderProvider>().getAll(
        filter: {'Status': enumToApi(OrderStatus.open), 'MyOrdersOnly': true},
      );
      orders.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
      if (mounted) {
        setState(() {
          _orders = orders;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final orders = _orders;
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Active Tables',
        subtitle: orders == null ? null : '${orders.length} ${orders.length == 1 ? 'table' : 'tables'} with orders',
      ),
      body: _error != null && orders == null
          ? ErrorView(error: _error!, onRetry: _load)
          : orders == null
          ? const LoadingView()
          : RefreshIndicator(
              onRefresh: _load,
              child: orders.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        EmptyView(icon: Icons.receipt_long_outlined, message: 'You have no open orders.'),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (_, index) {
                        final order = orders[index];
                        return OrderCard(
                          order: order,
                          onChanged: _load,
                          onAddItems: () =>
                              _open(MenuScreen(tableId: order.tableId, tableNumber: order.tableNumber, order: order)),
                          onPayment: () => _open(PaymentScreen(order: order)),
                        );
                      },
                    ),
            ),
    );
  }
}
