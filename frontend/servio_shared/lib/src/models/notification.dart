import 'enums.dart';
import 'json.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.orderTicketId,
    this.reservationId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] as int,
    title: json['title'] as String,
    body: json['body'] as String,
    type: toEnum(NotificationType.values, json['type']),
    isRead: json['isRead'] as bool,
    createdAt: toLocalDate(json['createdAt']),
    orderTicketId: json['orderTicketId'] as int?,
    reservationId: json['reservationId'] as int?,
  );

  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final int? orderTicketId;
  final int? reservationId;
}
