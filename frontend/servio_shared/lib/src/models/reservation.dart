import 'enums.dart';
import 'json.dart';

class Reservation {
  const Reservation({
    required this.id,
    required this.tableId,
    required this.tableNumber,
    required this.guestName,
    required this.guestPhone,
    this.guestEmail,
    required this.partySize,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.note,
    required this.createdByName,
    required this.createdAt,
    required this.history,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    id: json['id'] as int,
    tableId: json['tableId'] as int,
    tableNumber: json['tableNumber'] as int,
    guestName: json['guestName'] as String,
    guestPhone: json['guestPhone'] as String,
    guestEmail: json['guestEmail'] as String?,
    partySize: json['partySize'] as int,
    startTime: toLocalDate(json['startTime']),
    endTime: toLocalDate(json['endTime']),
    status: toEnum(ReservationStatus.values, json['status']),
    note: json['note'] as String?,
    createdByName: json['createdByName'] as String,
    createdAt: toLocalDate(json['createdAt']),
    history: toList(json['history'], StatusHistoryEntry.fromJson),
  );

  final int id;
  final int tableId;
  final int tableNumber;
  final String guestName;
  final String guestPhone;
  final String? guestEmail;
  final int partySize;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final String? note;
  final String createdByName;
  final DateTime createdAt;
  final List<StatusHistoryEntry> history;

  bool get isActive => status == ReservationStatus.pending || status == ReservationStatus.confirmed;
}

/// One audit trail entry: who changed the status, when and why.
class StatusHistoryEntry {
  const StatusHistoryEntry({
    this.fromStatus,
    required this.toStatus,
    required this.changedByName,
    this.reason,
    required this.changedAt,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) => StatusHistoryEntry(
    fromStatus: json['fromStatus'] as String?,
    toStatus: json['toStatus'] as String,
    changedByName: json['changedByName'] as String,
    reason: json['reason'] as String?,
    changedAt: toLocalDate(json['changedAt']),
  );

  final String? fromStatus;
  final String toStatus;
  final String changedByName;
  final String? reason;
  final DateTime changedAt;
}
