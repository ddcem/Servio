import 'enums.dart';
import 'json.dart';

class Payment {
  const Payment({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.tableNumber,
    required this.paymentMethod,
    required this.status,
    required this.orderTotal,
    required this.tipPercent,
    required this.tipAmount,
    required this.amount,
    this.cashReceived,
    this.changeGiven,
    this.capturedAmount,
    required this.refundedAmount,
    required this.refundableAmount,
    required this.currencyCode,
    required this.currencySymbol,
    required this.processedByName,
    required this.createdAt,
    this.completedAt,
    required this.refunds,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as int,
    orderId: json['orderId'] as int,
    orderNumber: json['orderNumber'] as String,
    tableNumber: json['tableNumber'] as int,
    paymentMethod: json['paymentMethod'] as String,
    status: toEnum(PaymentStatus.values, json['status']),
    orderTotal: toDouble(json['orderTotal']),
    tipPercent: toDouble(json['tipPercent']),
    tipAmount: toDouble(json['tipAmount']),
    amount: toDouble(json['amount']),
    cashReceived: toDoubleOrNull(json['cashReceived']),
    changeGiven: toDoubleOrNull(json['changeGiven']),
    capturedAmount: toDoubleOrNull(json['capturedAmount']),
    refundedAmount: toDouble(json['refundedAmount']),
    refundableAmount: toDouble(json['refundableAmount']),
    currencyCode: json['currencyCode'] as String,
    currencySymbol: json['currencySymbol'] as String,
    processedByName: json['processedByName'] as String,
    createdAt: toLocalDate(json['createdAt']),
    completedAt: toLocalDateOrNull(json['completedAt']),
    refunds: toList(json['refunds'], Refund.fromJson),
  );

  final int id;
  final int orderId;
  final String orderNumber;
  final int tableNumber;
  final String paymentMethod;
  final PaymentStatus status;
  final double orderTotal;
  final double tipPercent;
  final double tipAmount;
  final double amount;
  final double? cashReceived;
  final double? changeGiven;
  final double? capturedAmount;
  final double refundedAmount;
  final double refundableAmount;
  final String currencyCode;
  final String currencySymbol;
  final String processedByName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final List<Refund> refunds;

  bool get canRefund => refundableAmount > 0;
}

class Refund {
  const Refund({
    required this.id,
    required this.amount,
    required this.reason,
    required this.status,
    required this.refundedByName,
    required this.createdAt,
  });

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    id: json['id'] as int,
    amount: toDouble(json['amount']),
    reason: json['reason'] as String,
    status: toEnum(RefundStatus.values, json['status']),
    refundedByName: json['refundedByName'] as String,
    createdAt: toLocalDate(json['createdAt']),
  );

  final int id;
  final double amount;
  final String reason;
  final RefundStatus status;
  final String refundedByName;
  final DateTime createdAt;
}

class PayPalCheckout {
  const PayPalCheckout({required this.paymentId, required this.approvalUrl, required this.amount, required this.currencyCode});

  factory PayPalCheckout.fromJson(Map<String, dynamic> json) => PayPalCheckout(
    paymentId: json['paymentId'] as int,
    approvalUrl: json['approvalUrl'] as String,
    amount: toDouble(json['amount']),
    currencyCode: json['currencyCode'] as String,
  );

  final int paymentId;
  final String approvalUrl;
  final double amount;
  final String currencyCode;
}
