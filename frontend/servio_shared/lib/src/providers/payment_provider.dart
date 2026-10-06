import '../api/api_client.dart';
import '../models/payment.dart';
import 'base_provider.dart';

class PaymentProvider extends ReadProvider<Payment> {
  PaymentProvider(ApiClient api) : super(api, 'payments');

  @override
  Payment fromJson(Map<String, dynamic> json) => Payment.fromJson(json);

  Future<Payment> payCash(int orderId, int tipPercent, double cashReceived) async => fromJson(
    await api.post('$endpoint/cash', {'orderId': orderId, 'tipPercent': tipPercent, 'cashReceived': cashReceived})
        as Map<String, dynamic>,
  );

  Future<PayPalCheckout> startPayPal(int orderId, int tipPercent) async => PayPalCheckout.fromJson(
    await api.post('$endpoint/paypal', {'orderId': orderId, 'tipPercent': tipPercent}) as Map<String, dynamic>,
  );

  /// The server captures the approved PayPal order; safe to call more than once.
  Future<Payment> capturePayPal(int paymentId) async =>
      fromJson(await api.post('$endpoint/$paymentId/paypal/capture') as Map<String, dynamic>);

  Future<Payment> cancel(int paymentId) async => fromJson(await api.post('$endpoint/$paymentId/cancel') as Map<String, dynamic>);

  Future<Payment> refund(int paymentId, double amount, String reason) async =>
      fromJson(await api.post('$endpoint/$paymentId/refunds', {'amount': amount, 'reason': reason}) as Map<String, dynamic>);
}
