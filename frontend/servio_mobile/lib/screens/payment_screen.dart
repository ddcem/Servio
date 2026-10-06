import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import '../widgets/gradient_app_bar.dart';
import 'paypal_checkout_screen.dart';

enum _Method { cash, card }

/// Settles an order: choose a tip, then take cash (with change) or a card payment through PayPal.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, required this.order});

  final Order order;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _tips = [10, 15, 20, 25];

  late final _payments = context.read<PaymentProvider>();
  int _tipPercent = 0;
  _Method? _method;
  String _cash = '';
  bool _busy = false;

  Order get _order => widget.order;

  String _money(double value) => Formatters.money(value, _order.currencySymbol);

  /// Same as the server: the tip is a percentage of the subtotal, rounded to cents.
  double get _tip => (_order.subtotal * _tipPercent).roundToDouble() / 100;
  double get _amount => _order.total + _tip;
  double get _cashReceived => double.tryParse(_cash) ?? 0;
  double get _change => _cashReceived - _amount;

  bool get _waitingForKitchen =>
      _order.tickets.any((t) => t.status == TicketStatus.newTicket || t.status == TicketStatus.preparing);

  void _press(String key) {
    setState(() {
      if (key == 'C') {
        _cash = '';
      } else if (key == '.') {
        if (!_cash.contains('.')) _cash = _cash.isEmpty ? '0.' : '$_cash.';
      } else {
        final decimals = _cash.contains('.') ? _cash.length - _cash.indexOf('.') - 1 : 0;
        if (decimals < 2 && _cash.length < 9) _cash = _cash == '0' ? key : _cash + key;
      }
    });
  }

  Future<void> _payCash() async {
    setState(() => _busy = true);
    try {
      final payment = await _payments.payCash(_order.id, _tipPercent, _cashReceived);
      if (mounted) await _done(payment);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _payCard() async {
    setState(() => _busy = true);
    try {
      final checkout = await _payments.startPayPal(_order.id, _tipPercent);
      if (!mounted) return;
      final approved = await Navigator.of(context)
          .push<bool>(MaterialPageRoute(builder: (_) => PayPalCheckoutScreen(checkout: checkout)));
      if (!mounted) return;
      if (approved != true) {
        await _payments.cancel(checkout.paymentId);
        if (mounted) showError(context, 'The PayPal payment was cancelled. No money was taken.');
        return;
      }
      final payment = await _capture(checkout.paymentId);
      if (payment != null && mounted) await _done(payment);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// PayPal can take a moment to settle an approval, so a failed capture can be retried.
  Future<Payment?> _capture(int paymentId) async {
    while (true) {
      try {
        return await _payments.capturePayPal(paymentId);
      } on ApiException catch (e) {
        if (!mounted) return null;
        final retry = await confirmAction(context, title: 'Payment not confirmed', message: e.message, confirmLabel: 'Try again');
        if (!retry) {
          try {
            await _payments.cancel(paymentId);
          } on ApiException {
            // Already completed or cancelled on PayPal's side; the order screen shows the real state.
          }
          return null;
        }
      }
    }
  }

  Future<void> _done(Payment payment) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: ServioColors.success, size: 56),
        title: Text('Table ${payment.tableNumber} paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _line('Paid by', payment.paymentMethod),
            _line('Amount', _money(payment.amount)),
            if (payment.tipAmount > 0) _line('Tip', _money(payment.tipAmount)),
            if (payment.changeGiven != null) _line('Change', _money(payment.changeGiven!), bold: true),
          ],
        ),
        actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
    if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cashReady = _cashReceived > 0 && _change >= -0.004;

    return Scaffold(
      appBar: GradientAppBar(title: 'Process Payment', subtitle: 'Table ${_order.tableNumber} · ${_order.orderNumber}'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_waitingForKitchen)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: ServioColors.warningLight, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top, color: ServioColors.warning),
                  SizedBox(width: 10),
                  Expanded(child: Text('Some items are still being prepared. The bill can be paid once everything is ready.')),
                ],
              ),
            ),
          Card(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Total Amount',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ServioColors.textMuted),
                  ),
                  Text(
                    _money(_amount),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  for (final item in _order.items) _line('${item.menuItemName} × ${item.quantity}', _money(item.lineTotal)),
                  const Divider(height: 20),
                  _line('Subtotal', _money(_order.subtotal), muted: true),
                  _line('Tax (${_percent(_order.taxRate)})', _money(_order.taxAmount), muted: true),
                  if (_tipPercent > 0) _line('Tip ($_tipPercent%)', _money(_tip), muted: true),
                  const Divider(height: 20),
                  _line('Total', _money(_amount), bold: true, size: 18),
                  const SizedBox(height: 18),
                  const Text('Tip Amount', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final tip in _tips)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: tip == _tips.last ? 0 : 8),
                            child: _ChoiceButton(
                              label: '$tip%',
                              selected: _tipPercent == tip,
                              onTap: () => setState(() => _tipPercent = _tipPercent == tip ? 0 : tip),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_tipPercent > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '+ ${_money(_tip)} tip',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: ServioColors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _MethodButton(
                          icon: Icons.payments_outlined,
                          label: 'Cash',
                          color: ServioColors.success,
                          selected: _method == _Method.cash,
                          onTap: () => setState(() => _method = _Method.cash),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MethodButton(
                          icon: Icons.credit_card,
                          label: 'Card',
                          color: ServioColors.primary,
                          selected: _method == _Method.card,
                          onTap: () => setState(() => _method = _Method.card),
                        ),
                      ),
                    ],
                  ),
                  if (_method == _Method.cash) ...[const SizedBox(height: 16), _buildCash()],
                  if (_method == _Method.card)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'The guest pays on PayPal\'s secure page, by card or with a PayPal account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: ServioColors.textMuted),
                      ),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
                      onPressed: _busy || _waitingForKitchen || _method == null || (_method == _Method.cash && !cashReady)
                          ? null
                          : (_method == _Method.cash ? _payCash : _payCard),
                      icon: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(switch (_method) {
                        null => 'Select Payment Method',
                        _Method.cash => cashReady ? 'Complete Cash Payment' : 'Enter Cash Received',
                        _Method.card => 'Process Card Payment',
                      }, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCash() {
    final enough = _change >= -0.004;
    final suggestions = <double>{
      _amount,
      for (final note in [5, 10, 20, 50, 100]) (_amount / note).ceil() * note.toDouble(),
    }.where((x) => x >= _amount - 0.004).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Cash Received', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                _cash.isEmpty ? '–' : '${_order.currencySymbol}$_cash',
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
              ),
              if (_cashReceived > 0) ...[
                const Divider(height: 20, color: Color(0xFFBBF7D0)),
                Text(enough ? 'Change' : 'Still missing', textAlign: TextAlign.center),
                Text(
                  _money(_change.abs()),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: enough ? ServioColors.success : ServioColors.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final value in suggestions)
              ActionChip(
                label: Text(value == _amount ? 'Exact' : _money(value)),
                onPressed: () => setState(() => _cash = value.toStringAsFixed(2)),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ServioColors.background, borderRadius: BorderRadius.circular(14)),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.1,
            children: [
              for (final key in ['1', '2', '3', '4', '5', '6', '7', '8', '9', 'C', '0', '.'])
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _press(key),
                    child: Center(
                      child: Text(
                        key == 'C' ? 'Clear' : key,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: key == 'C' ? ServioColors.danger : ServioColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _percent(double value) => value == value.roundToDouble() ? '${value.toInt()}%' : '$value%';

  static Widget _line(String label, String value, {bool bold = false, bool muted = false, double size = 14}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: muted ? ServioColors.textMuted : null,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.w600),
        ),
      ],
    ),
  );
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? ServioColors.primary : ServioColors.background,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Center(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selected ? Colors.white : null),
          ),
        ),
      ),
    ),
  );
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? color : color.withValues(alpha: 0.12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: selected ? BorderSide(color: color.withValues(alpha: 0.4), width: 3) : BorderSide.none,
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: selected ? Colors.white : color),
            ),
          ],
        ),
      ),
    ),
  );
}
