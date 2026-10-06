import 'json.dart';

DateTime _date(Object? value) => DateTime.parse(value as String);

class SalesReport {
  const SalesReport({
    required this.from,
    required this.to,
    required this.currencySymbol,
    required this.revenue,
    required this.taxCollected,
    required this.tips,
    required this.refunds,
    required this.netRevenue,
    required this.orderCount,
    required this.guestCount,
    required this.averageBill,
    required this.cancelledOrderCount,
    required this.daily,
    required this.topItems,
    required this.leastSoldItems,
    required this.categories,
    required this.paymentMethods,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) => SalesReport(
    from: _date(json['from']),
    to: _date(json['to']),
    currencySymbol: json['currencySymbol'] as String,
    revenue: toDouble(json['revenue']),
    taxCollected: toDouble(json['taxCollected']),
    tips: toDouble(json['tips']),
    refunds: toDouble(json['refunds']),
    netRevenue: toDouble(json['netRevenue']),
    orderCount: json['orderCount'] as int,
    guestCount: json['guestCount'] as int,
    averageBill: toDouble(json['averageBill']),
    cancelledOrderCount: json['cancelledOrderCount'] as int,
    daily: toList(json['daily'], (e) => DailySales(_date(e['date']), toDouble(e['revenue']), e['orderCount'] as int)),
    topItems: toList(json['topItems'], ItemSales.fromJson),
    leastSoldItems: toList(json['leastSoldItems'], ItemSales.fromJson),
    categories: toList(
      json['categories'],
      (e) => CategorySales(e['categoryName'] as String, e['quantity'] as int, toDouble(e['revenue'])),
    ),
    paymentMethods: toList(
      json['paymentMethods'],
      (e) => PaymentMethodSales(e['paymentMethod'] as String, e['paymentCount'] as int, toDouble(e['amount'])),
    ),
  );

  final DateTime from;
  final DateTime to;
  final String currencySymbol;
  final double revenue;
  final double taxCollected;
  final double tips;
  final double refunds;
  final double netRevenue;
  final int orderCount;
  final int guestCount;
  final double averageBill;
  final int cancelledOrderCount;
  final List<DailySales> daily;
  final List<ItemSales> topItems;
  final List<ItemSales> leastSoldItems;
  final List<CategorySales> categories;
  final List<PaymentMethodSales> paymentMethods;
}

class DailySales {
  const DailySales(this.date, this.revenue, this.orderCount);

  final DateTime date;
  final double revenue;
  final int orderCount;
}

class ItemSales {
  const ItemSales({
    required this.menuItemId,
    required this.name,
    required this.categoryName,
    required this.hasImage,
    required this.quantity,
    required this.revenue,
  });

  factory ItemSales.fromJson(Map<String, dynamic> json) => ItemSales(
    menuItemId: json['menuItemId'] as int,
    name: json['name'] as String,
    categoryName: json['categoryName'] as String,
    hasImage: json['hasImage'] as bool,
    quantity: json['quantity'] as int,
    revenue: toDouble(json['revenue']),
  );

  final int menuItemId;
  final String name;
  final String categoryName;
  final bool hasImage;
  final int quantity;
  final double revenue;
}

class CategorySales {
  const CategorySales(this.categoryName, this.quantity, this.revenue);

  final String categoryName;
  final int quantity;
  final double revenue;
}

class PaymentMethodSales {
  const PaymentMethodSales(this.paymentMethod, this.paymentCount, this.amount);

  final String paymentMethod;
  final int paymentCount;
  final double amount;
}

class StaffReport {
  const StaffReport({
    required this.from,
    required this.to,
    required this.currencySymbol,
    required this.waiters,
    required this.stations,
  });

  factory StaffReport.fromJson(Map<String, dynamic> json) => StaffReport(
    from: _date(json['from']),
    to: _date(json['to']),
    currencySymbol: json['currencySymbol'] as String,
    waiters: toList(json['waiters'], WaiterPerformance.fromJson),
    stations: toList(json['stations'], StationPerformance.fromJson),
  );

  final DateTime from;
  final DateTime to;
  final String currencySymbol;
  final List<WaiterPerformance> waiters;
  final List<StationPerformance> stations;
}

class WaiterPerformance {
  const WaiterPerformance({
    required this.userId,
    required this.name,
    required this.isActive,
    required this.orderCount,
    required this.guestCount,
    required this.revenue,
    required this.averageBill,
    required this.tips,
    required this.suggestionsShown,
    required this.suggestionsAccepted,
    this.suggestionAcceptanceRate,
  });

  factory WaiterPerformance.fromJson(Map<String, dynamic> json) => WaiterPerformance(
    userId: json['userId'] as int,
    name: json['name'] as String,
    isActive: json['isActive'] as bool,
    orderCount: json['orderCount'] as int,
    guestCount: json['guestCount'] as int,
    revenue: toDouble(json['revenue']),
    averageBill: toDouble(json['averageBill']),
    tips: toDouble(json['tips']),
    suggestionsShown: json['suggestionsShown'] as int,
    suggestionsAccepted: json['suggestionsAccepted'] as int,
    suggestionAcceptanceRate: toDoubleOrNull(json['suggestionAcceptanceRate']),
  );

  final int userId;
  final String name;
  final bool isActive;
  final int orderCount;
  final int guestCount;
  final double revenue;
  final double averageBill;
  final double tips;
  final int suggestionsShown;
  final int suggestionsAccepted;
  final double? suggestionAcceptanceRate;
}

class StationPerformance {
  const StationPerformance({
    required this.stationName,
    required this.ticketCount,
    this.averageMinutesToStart,
    this.averageMinutesToReady,
  });

  factory StationPerformance.fromJson(Map<String, dynamic> json) => StationPerformance(
    stationName: json['stationName'] as String,
    ticketCount: json['ticketCount'] as int,
    averageMinutesToStart: toDoubleOrNull(json['averageMinutesToStart']),
    averageMinutesToReady: toDoubleOrNull(json['averageMinutesToReady']),
  );

  final String stationName;
  final int ticketCount;
  final double? averageMinutesToStart;
  final double? averageMinutesToReady;
}
