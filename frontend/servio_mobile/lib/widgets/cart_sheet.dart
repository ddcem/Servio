import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';

import '../models/cart.dart';

/// The current round: change quantities, add notes for the kitchen, then send. Returns true to send.
Future<bool?> showCartSheet(BuildContext context, {required Cart cart, required String currency, Order? order}) =>
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _CartSheet(cart: cart, currency: currency, order: order),
    );

class _CartSheet extends StatelessWidget {
  const _CartSheet({required this.cart, required this.currency, this.order});

  final Cart cart;
  final String currency;
  final Order? order;

  String _money(double value) => Formatters.money(value, currency);

  Future<void> _editNote(BuildContext context, CartLine line) async {
    final controller = TextEditingController(text: line.note);
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Note for ${line.item.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 200,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(hintText: 'e.g. no onions, well done'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (note != null) cart.setNote(line, note);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: cart,
    builder: (context, _) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Current Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (cart.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: EmptyView(
                icon: Icons.remove_shopping_cart_outlined,
                message: 'The cart is empty. Tap menu items to add them.',
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  for (final line in cart.lines)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                      decoration: BoxDecoration(color: ServioColors.surfaceMuted, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(line.item.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                    Text(
                                      '${_money(line.item.price)} each',
                                      style: const TextStyle(color: ServioColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove',
                                color: ServioColors.danger,
                                onPressed: () => cart.remove(line),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'One less',
                                      onPressed: () => cart.setQuantity(line, line.quantity - 1),
                                      icon: const Icon(Icons.remove),
                                    ),
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        '${line.quantity}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'One more',
                                      onPressed: line.quantity < 50 ? () => cart.setQuantity(line, line.quantity + 1) : null,
                                      icon: const Icon(Icons.add),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  _money(line.lineTotal),
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                            onPressed: () => _editNote(context, line),
                            icon: Icon(line.note == null ? Icons.edit_note : Icons.sticky_note_2_outlined, size: 20),
                            label: Text(line.note ?? 'Add note', maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          Container(
            color: ServioColors.surfaceMuted,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  if (order != null) _row('Already on ${order!.orderNumber}', _money(order!.total)),
                  _row('Subtotal', _money(cart.subtotal)),
                  _row('Tax (${_percent(cart.taxRate)})', _money(cart.tax)),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order == null ? 'Total' : 'This round',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(_money(cart.total), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (!cart.isEmpty)
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: ServioColors.danger),
                      onPressed: cart.clear,
                      child: const Text('Clear All', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: cart.isEmpty ? null : () => Navigator.pop(context, true),
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Send Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  static String _percent(double value) => value == value.roundToDouble() ? '${value.toInt()}%' : '$value%';

  static Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: ServioColors.textMuted, fontSize: 15)),
        ),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    ),
  );
}
