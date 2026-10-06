import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

/// An open order: its items with their preparation status, ready tickets to serve, and the
/// Add Items and Payment actions.
class OrderCard extends StatefulWidget {
  const OrderCard({super.key, required this.order, required this.onAddItems, required this.onPayment, required this.onChanged});

  final Order order;
  final VoidCallback onAddItems;
  final VoidCallback onPayment;

  /// Called after a ticket was served, so the parent reloads.
  final VoidCallback onChanged;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final _serving = <int>{};

  Future<void> _serve(OrderTicketSummary ticket) async {
    setState(() => _serving.add(ticket.id));
    try {
      await context.read<OrderTicketProvider>().serve(ticket.id);
      if (mounted) showSuccess(context, '${ticket.stationName} order for table ${widget.order.tableNumber} served.');
      widget.onChanged();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _serving.remove(ticket.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final menu = context.read<MenuItemProvider>();
    final headers = context.read<ApiClient>().authHeaders;
    final ready = order.tickets.where((t) => t.status == TicketStatus.ready).toList();
    final itemCount = order.items.fold(0, (sum, item) => sum + item.quantity);
    String money(double value) => Formatters.money(value, order.currencySymbol);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                      Row(
                        children: [
                          Text('Table ${order.tableNumber}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.people_outline, size: 18, color: ServioColors.textMuted),
                          const SizedBox(width: 4),
                          Text('${order.guestCount} guests', style: const TextStyle(color: ServioColors.textMuted)),
                        ],
                      ),
                      Text(
                        '$itemCount items · ${order.orderNumber} · since ${Formatters.time(order.openedAt)}',
                        style: const TextStyle(color: ServioColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total', style: TextStyle(color: ServioColors.textMuted)),
                    Text(money(order.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final ticket in ready)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                decoration: BoxDecoration(
                  color: ServioColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ServioColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.room_service_outlined, color: ServioColors.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${ticket.stationName} order is ready',
                        style: const TextStyle(color: ServioColors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: ServioColors.success),
                      onPressed: _serving.contains(ticket.id) ? null : () => _serve(ticket),
                      child: const Text('Mark served'),
                    ),
                  ],
                ),
              ),
            for (final item in order.items)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    AuthImage(url: menu.imageUrl(item.menuItemId), headers: headers, hasImage: true, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.menuItemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            '${money(item.unitPrice)} × ${item.quantity}',
                            style: const TextStyle(color: ServioColors.textMuted, fontSize: 13),
                          ),
                          if (item.note != null)
                            Text(
                              item.note!,
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: ServioColors.warning),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(money(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        TicketStatusChip(item.ticketStatus),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: widget.onAddItems,
                icon: const Icon(Icons.add),
                label: const Text('Add Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF3DA34A)),
                onPressed: widget.onPayment,
                icon: const Icon(Icons.credit_card),
                label: const Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketStatusChip extends StatelessWidget {
  const TicketStatusChip(this.status, {super.key});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, background) = switch (status) {
      TicketStatus.newTicket => (ServioColors.primary, ServioColors.infoLight),
      TicketStatus.preparing => (ServioColors.warning, ServioColors.warningLight),
      TicketStatus.ready => (ServioColors.success, ServioColors.successLight),
      TicketStatus.served => (ServioColors.textMuted, ServioColors.border),
      TicketStatus.cancelled => (ServioColors.danger, ServioColors.dangerLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
