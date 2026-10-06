enum CourseType {
  appetizer('Appetizer'),
  mainCourse('Main course'),
  side('Side'),
  dessert('Dessert'),
  drink('Drink');

  const CourseType(this.label);
  final String label;
}

enum TableStatus { available, occupied, reserved }

enum ReservationStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  completed('Completed'),
  cancelled('Cancelled'),
  noShow('No-show');

  const ReservationStatus(this.label);
  final String label;
}

enum OrderStatus { open, completed, cancelled }

enum TicketStatus {
  newTicket('New'),
  preparing('Preparing'),
  ready('Ready'),
  served('Served'),
  cancelled('Cancelled');

  const TicketStatus(this.label);
  final String label;

  /// The API calls the first status "New", which is a reserved word in Dart.
  static TicketStatus fromApi(Object? value) => (value as String).toLowerCase() == 'new'
      ? newTicket
      : TicketStatus.values.byName(value[0].toLowerCase() + value.substring(1));

  String get apiName => this == newTicket ? 'New' : label;
}

enum PaymentStatus {
  pending('Pending'),
  completed('Paid'),
  failed('Failed'),
  cancelled('Cancelled'),
  partiallyRefunded('Partially refunded'),
  refunded('Refunded');

  const PaymentStatus(this.label);
  final String label;
}

enum RefundStatus { pending, completed, failed }

enum NotificationType {
  ticketReady,
  ticketCancelled,
  reservationCreated,
  reservationConfirmed,
  reservationCancelled,
  paymentCompleted,
  refundIssued,
}
