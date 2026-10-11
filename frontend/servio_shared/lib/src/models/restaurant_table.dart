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
    this.assignedWaiterId,
    this.assignedWaiterName,
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
    assignedWaiterId: json['assignedWaiterId'] as int?,
    assignedWaiterName: json['assignedWaiterName'] as String?,
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

  /// The waiter serving the table this shift; null when any waiter may serve it.
  final int? assignedWaiterId;
  final String? assignedWaiterName;
  final int? currentOrderId;
  final double? currentOrderTotal;
  final int? currentGuestCount;
  final UpcomingReservation? upcomingReservation;
  final bool hasHistory;

  /// Whether the logged-in waiter may take orders here: the table is theirs or nobody's.
  bool isServableBy(int userId) => assignedWaiterId == null || assignedWaiterId == userId;

  /// The same table assigned to another waiter (or to nobody), e.g. right after a drag on the assignment board.
  RestaurantTable withWaiter(int? waiterId, String? waiterName) => RestaurantTable(
    id: id,
    number: number,
    capacity: capacity,
    areaId: areaId,
    areaName: areaName,
    isActive: isActive,
    status: status,
    assignedWaiterId: waiterId,
    assignedWaiterName: waiterId == null ? null : waiterName,
    currentOrderId: currentOrderId,
    currentOrderTotal: currentOrderTotal,
    currentGuestCount: currentGuestCount,
    upcomingReservation: upcomingReservation,
    hasHistory: hasHistory,
  );
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
