import 'enums.dart';
import 'json.dart';

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.tableId,
    required this.tableNumber,
    required this.guestCount,
    required this.waiterId,
    required this.waiterName,
    required this.status,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.currencyCode,
    required this.currencySymbol,
    required this.openedAt,
    this.closedAt,
    this.cancellationReason,
    required this.isPaid,
    required this.items,
    required this.tickets,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as int,
    orderNumber: json['orderNumber'] as String,
    tableId: json['tableId'] as int,
    tableNumber: json['tableNumber'] as int,
    guestCount: json['guestCount'] as int,
    waiterId: json['waiterId'] as int,
    waiterName: json['waiterName'] as String,
    status: toEnum(OrderStatus.values, json['status']),
    subtotal: toDouble(json['subtotal']),
    taxRate: toDouble(json['taxRate']),
    taxAmount: toDouble(json['taxAmount']),
    total: toDouble(json['total']),
    currencyCode: json['currencyCode'] as String,
    currencySymbol: json['currencySymbol'] as String,
    openedAt: toLocalDate(json['openedAt']),
    closedAt: toLocalDateOrNull(json['closedAt']),
    cancellationReason: json['cancellationReason'] as String?,
    isPaid: json['isPaid'] as bool,
    items: toList(json['items'], OrderItem.fromJson),
    tickets: toList(json['tickets'], OrderTicketSummary.fromJson),
  );

  final int id;
  final String orderNumber;
  final int tableId;
  final int tableNumber;
  final int guestCount;
  final int waiterId;
  final String waiterName;
  final OrderStatus status;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String currencyCode;
  final String currencySymbol;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? cancellationReason;
  final bool isPaid;
  final List<OrderItem> items;
  final List<OrderTicketSummary> tickets;

  /// Lines that are charged (items on cancelled tickets are not).
  List<OrderItem> get chargedItems => items.where((x) => x.ticketStatus != TicketStatus.cancelled).toList();

  int get itemCount => chargedItems.fold(0, (sum, x) => sum + x.quantity);

  /// The first ticket the kitchen or bar is still working on; the bill cannot be paid while one exists.
  OrderTicketSummary? get ticketInProgress =>
      tickets.where((x) => x.status == TicketStatus.newTicket || x.status == TicketStatus.preparing).firstOrNull;
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.note,
    required this.orderTicketId,
    required this.ticketStatus,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as int,
    menuItemId: json['menuItemId'] as int,
    menuItemName: json['menuItemName'] as String,
    quantity: json['quantity'] as int,
    unitPrice: toDouble(json['unitPrice']),
    lineTotal: toDouble(json['lineTotal']),
    note: json['note'] as String?,
    orderTicketId: json['orderTicketId'] as int,
    ticketStatus: TicketStatus.fromApi(json['ticketStatus']),
  );

  final int id;
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String? note;
  final int orderTicketId;
  final TicketStatus ticketStatus;
}

class OrderTicketSummary {
  const OrderTicketSummary({
    required this.id,
    required this.ticketNumber,
    required this.stationName,
    required this.status,
    required this.createdAt,
  });

  factory OrderTicketSummary.fromJson(Map<String, dynamic> json) => OrderTicketSummary(
    id: json['id'] as int,
    ticketNumber: json['ticketNumber'] as String,
    stationName: json['stationName'] as String,
    status: TicketStatus.fromApi(json['status']),
    createdAt: toLocalDate(json['createdAt']),
  );

  final int id;
  final String ticketNumber;
  final String stationName;
  final TicketStatus status;
  final DateTime createdAt;
}

/// A ticket on the kitchen or bar display.
class OrderTicket {
  const OrderTicket({
    required this.id,
    required this.ticketNumber,
    required this.orderId,
    required this.orderNumber,
    required this.tableNumber,
    required this.waiterName,
    required this.stationId,
    required this.stationName,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.readyAt,
    this.servedAt,
    required this.items,
  });

  factory OrderTicket.fromJson(Map<String, dynamic> json) => OrderTicket(
    id: json['id'] as int,
    ticketNumber: json['ticketNumber'] as String,
    orderId: json['orderId'] as int,
    orderNumber: json['orderNumber'] as String,
    tableNumber: json['tableNumber'] as int,
    waiterName: json['waiterName'] as String,
    stationId: json['stationId'] as int,
    stationName: json['stationName'] as String,
    status: TicketStatus.fromApi(json['status']),
    createdAt: toLocalDate(json['createdAt']),
    startedAt: toLocalDateOrNull(json['startedAt']),
    readyAt: toLocalDateOrNull(json['readyAt']),
    servedAt: toLocalDateOrNull(json['servedAt']),
    items: toList(json['items'], OrderTicketItem.fromJson),
  );

  final int id;
  final String ticketNumber;
  final int orderId;
  final String orderNumber;
  final int tableNumber;
  final String waiterName;
  final int stationId;
  final String stationName;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? readyAt;
  final DateTime? servedAt;
  final List<OrderTicketItem> items;
}

class OrderTicketItem {
  const OrderTicketItem({required this.menuItemId, required this.menuItemName, required this.quantity, this.note});

  factory OrderTicketItem.fromJson(Map<String, dynamic> json) => OrderTicketItem(
    menuItemId: json['menuItemId'] as int,
    menuItemName: json['menuItemName'] as String,
    quantity: json['quantity'] as int,
    note: json['note'] as String?,
  );

  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final String? note;
}

class StationSummary {
  const StationSummary({
    required this.stationId,
    required this.stationName,
    required this.newCount,
    required this.preparingCount,
    this.oldestWaitingSince,
    this.averageMinutesToReadyToday,
    required this.completedToday,
  });

  factory StationSummary.fromJson(Map<String, dynamic> json) => StationSummary(
    stationId: json['stationId'] as int,
    stationName: json['stationName'] as String,
    newCount: json['newCount'] as int,
    preparingCount: json['preparingCount'] as int,
    oldestWaitingSince: toLocalDateOrNull(json['oldestWaitingSince']),
    averageMinutesToReadyToday: toDoubleOrNull(json['averageMinutesToReadyToday']),
    completedToday: json['completedToday'] as int,
  );

  final int stationId;
  final String stationName;
  final int newCount;
  final int preparingCount;
  final DateTime? oldestWaitingSince;
  final double? averageMinutesToReadyToday;
  final int completedToday;
}
