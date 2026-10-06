import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import '../widgets/order_card.dart';
import 'receipt_screen.dart';

/// A closed order: what was ordered, how it was paid (with refunds) and the receipt.
class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late Future<List<Payment>> _payments = _load();

  Future<List<Payment>> _load() => context.read<PaymentProvider>().getAll(filter: {'OrderId': widget.order.id});

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    String money(double value) => Formatters.money(value, order.currencySymbol);

    return Scaffold(
      appBar: GradientAppBar(title: 'Table ${order.tableNumber}', subtitle: order.orderNumber),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${order.guestCount} guests · ${order.waiterName}',
                          style: const TextStyle(color: ServioColors.textMuted),
                        ),
                      ),
                      StatusBadge(
                        order.status == OrderStatus.completed ? 'Paid' : 'Cancelled',
                        color: order.status == OrderStatus.completed ? ServioColors.success : ServioColors.danger,
                        background: order.status == OrderStatus.completed ? ServioColors.successLight : ServioColors.dangerLight,
                      ),
                    ],
                  ),
                  Text(
                    'Opened ${Formatters.dateTime(order.openedAt)}'
                    '${order.closedAt == null ? '' : ' · closed ${Formatters.time(order.closedAt!)}'}',
                    style: const TextStyle(color: ServioColors.textMuted),
                  ),
                  if (order.cancellationReason != null) ...[
                    const SizedBox(height: 8),
                    Text('Reason: ${order.cancellationReason}', style: const TextStyle(color: ServioColors.danger)),
                  ],
                  const Divider(height: 24),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text('${item.menuItemName} × ${item.quantity}')),
                          if (item.ticketStatus == TicketStatus.cancelled) ...[
                            const TicketStatusChip(TicketStatus.cancelled),
                            const SizedBox(width: 8),
                          ],
                          Text(money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Text(money(order.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  VatNote(total: order.total, taxRate: order.taxRate, currency: order.currencySymbol),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Payment>>(
            future: _payments,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(error: snapshot.error!, onRetry: () => setState(() => _payments = _load()));
              }
              if (!snapshot.hasData) return const LoadingView();
              final payments = snapshot.data!.where((p) => p.status != PaymentStatus.cancelled).toList();
              if (payments.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final payment in payments) _PaymentCard(payment: payment, money: money),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment, required this.money});

  final Payment payment;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    final paid = payment.status != PaymentStatus.pending && payment.status != PaymentStatus.failed;
    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(color: ServioColors.textMuted)),
          ),
          Text(value),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(payment.paymentMethod == 'Cash' ? Icons.payments_outlined : Icons.credit_card, color: ServioColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(payment.paymentMethod, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                Text(payment.status.label, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            line('Amount paid', money(payment.capturedAmount ?? payment.amount)),
            if (payment.tipAmount > 0) line('Tip (${payment.tipPercent.toStringAsFixed(0)}%)', money(payment.tipAmount)),
            if (payment.cashReceived != null) line('Cash received', money(payment.cashReceived!)),
            if (payment.changeGiven != null) line('Change', money(payment.changeGiven!)),
            for (final refund in payment.refunds) line('Refund ${Formatters.date(refund.createdAt)}', '−${money(refund.amount)}'),
            line('Taken by', payment.processedByName),
            if (paid) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ReceiptScreen(paymentId: payment.id, title: 'Table ${payment.tableNumber} · ${payment.orderNumber}'),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text('View receipt'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
