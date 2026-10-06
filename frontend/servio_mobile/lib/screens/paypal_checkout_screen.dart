import 'package:flutter/material.dart';
import 'package:servio_shared/servio_shared.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// PayPal's approval page. The guest logs in and approves; PayPal then redirects to
/// servio://paypal/return (approved) or servio://paypal/cancel, which closes this screen.
/// Returns true when the guest approved the payment.
class PayPalCheckoutScreen extends StatefulWidget {
  const PayPalCheckoutScreen({super.key, required this.checkout});

  final PayPalCheckout checkout;

  @override
  State<PayPalCheckoutScreen> createState() => _PayPalCheckoutScreenState();
}

class _PayPalCheckoutScreenState extends State<PayPalCheckoutScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) => setState(() => _progress = progress),
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && uri.scheme == 'servio') {
              _close(uri.path.contains('return'));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkout.approvalUrl));
  }

  void _close(bool approved) {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop(approved);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: ServioColors.textPrimary,
      leading: IconButton(tooltip: 'Cancel payment', icon: const Icon(Icons.close), onPressed: () => _close(false)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PayPal', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${widget.checkout.amount.toStringAsFixed(2)} ${widget.checkout.currencyCode}',
            style: const TextStyle(fontSize: 13, color: ServioColors.textMuted),
          ),
        ],
      ),
      bottom: _progress < 100
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(value: _progress / 100),
            )
          : null,
    ),
    body: WebViewWidget(controller: _controller),
  );
}
