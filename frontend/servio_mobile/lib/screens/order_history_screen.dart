import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import 'order_details_screen.dart';

/// The waiter's closed orders, newest first: paid ones with their receipts, or cancelled ones.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late final _orders = context.read<OrderProvider>();
  final _items = <Order>[];
  OrderStatus _status = OrderStatus.completed;
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    _page = 1;
    await _loadPage(replace: true);
  }

  Future<void> _loadPage({bool replace = false}) async {
    setState(() => _loading = true);
    try {
      final result = await _orders.getPage(filter: {'Status': enumToApi(_status), 'MyOrdersOnly': true}, page: _page);
      if (!mounted) return;
      setState(() {
        if (replace) _items.clear();
        _items.addAll(result.items);
        _hasMore = _items.length < result.totalCount;
        _error = null;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: GradientAppBar(title: l10n.orderHistory, subtitle: l10n.yourClosedOrders),
    body: Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SegmentedButton<OrderStatus>(
            segments: [
              ButtonSegment(value: OrderStatus.completed, label: Text(l10n.paid), icon: Icon(Icons.check_circle_outline)),
              ButtonSegment(value: OrderStatus.cancelled, label: Text(l10n.cancelled), icon: Icon(Icons.cancel_outlined)),
            ],
            selected: {_status},
            onSelectionChanged: (value) {
              setState(() => _status = value.first);
              _reload();
            },
          ),
        ),
        Expanded(
          child: _error != null && _items.isEmpty
              ? ErrorView(error: _error!, onRetry: _reload)
              : _items.isEmpty && _loading
              ? LoadingView()
              : RefreshIndicator(
                  onRefresh: _reload,
                  child: _items.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: 100),
                            EmptyView(icon: Icons.history, message: l10n.noOrdersYet),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _items.length + (_hasMore ? 1 : 0),
                          itemBuilder: (_, index) {
                            if (index == _items.length) {
                              return Center(
                                child: TextButton(
                                  onPressed: _loading
                                      ? null
                                      : () {
                                          _page++;
                                          _loadPage();
                                        },
                                  child: Text(l10n.loadMore),
                                ),
                              );
                            }
                            final order = _items[index];
                            final items = order.items.fold(0, (sum, item) => sum + item.quantity);
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: ServioColors.infoLight,
                                  child: Text(
                                    '${order.tableNumber}',
                                    style: const TextStyle(color: ServioColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  l10n.tableAndOrder(order.tableNumber, order.orderNumber),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  l10n.historyLine(
                                    Formatters.dateTime(order.closedAt ?? order.openedAt),
                                    l10n.itemCount(items),
                                    l10n.guestCount(order.guestCount),
                                  ),
                                ),
                                trailing: Text(
                                  Formatters.money(order.total, order.currencySymbol),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                onTap: () =>
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: order))),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    ),
  );
}
