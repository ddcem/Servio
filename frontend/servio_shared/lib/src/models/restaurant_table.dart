import 'enums.dart';
import 'json.dart';

class RestaurantTable {
  const RestaurantTable({
    required this.id,
    required this.number,
    required this.capacity,
    required this.areaId,
    required this.areaName,
    required this.isActive,
    required this.status,
    this.currentOrderId,
    this.currentOrderTotal,
    this.currentGuestCount,
    this.upcomingReservation,
    required this.hasHistory,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) => RestaurantTable(
    id: json['id'] as int,
    number: json['number'] as int,
    capacity: json['capacity'] as int,
    areaId: json['areaId'] as int,
    areaName: json['areaName'] as String,
    isActive: json['isActive'] as bool,
    status: toEnum(TableStatus.values, json['status']),
    currentOrderId: json['currentOrderId'] as int?,
    currentOrderTotal: toDoubleOrNull(json['currentOrderTotal']),
    currentGuestCount: json['currentGuestCount'] as int?,
    upcomingReservation: json['upcomingReservation'] == null
        ? null
        : UpcomingReservation.fromJson(json['upcomingReservation'] as Map<String, dynamic>),
    hasHistory: json['hasHistory'] as bool,
  );

  final int id;
  final int number;
  final int capacity;
  final int areaId;
  final String areaName;
  final bool isActive;
  final TableStatus status;
  final int? currentOrderId;
  final double? currentOrderTotal;
  final int? currentGuestCount;
  final UpcomingReservation? upcomingReservation;
  final bool hasHistory;
}

class UpcomingReservation {
  const UpcomingReservation({
    required this.id,
    required this.guestName,
    required this.partySize,
    required this.startTime,
    required this.endTime,
  });

  factory UpcomingReservation.fromJson(Map<String, dynamic> json) => UpcomingReservation(
    id: json['id'] as int,
    guestName: json['guestName'] as String,
    partySize: json['partySize'] as int,
    startTime: toLocalDate(json['startTime']),
    endTime: toLocalDate(json['endTime']),
  );

  final int id;
  final String guestName;
  final int partySize;
  final DateTime startTime;
  final DateTime endTime;
}
