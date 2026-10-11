import '../localization/language.dart';

enum CourseType {
  appetizer,
  mainCourse,
  side,
  dessert,
  drink;

  String get label => switch (this) {
    appetizer => l10n.courseAppetizer,
    mainCourse => l10n.courseMainCourse,
    side => l10n.courseSide,
    dessert => l10n.courseDessert,
    drink => l10n.courseDrink,
  };
}

enum TableStatus { available, occupied, reserved }

enum ReservationStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  noShow;

  String get label => switch (this) {
    pending => l10n.reservationPending,
    confirmed => l10n.reservationConfirmed,
    completed => l10n.reservationCompleted,
    cancelled => l10n.reservationCancelled,
    noShow => l10n.reservationNoShow,
  };
}

enum OrderStatus { open, completed, cancelled }

enum TicketStatus {
  newTicket,
  preparing,
  ready,
  served,
  cancelled;

  String get label => switch (this) {
    newTicket => l10n.ticketNew,
    preparing => l10n.ticketPreparing,
    ready => l10n.ticketReady,
    served => l10n.ticketServed,
    cancelled => l10n.ticketCancelled,
  };

  /// The API calls the first status "New", which is a reserved word in Dart.
  static TicketStatus fromApi(Object? value) => (value as String).toLowerCase() == 'new'
      ? newTicket
      : TicketStatus.values.byName(value[0].toLowerCase() + value.substring(1));

  String get apiName => this == newTicket ? 'New' : name[0].toUpperCase() + name.substring(1);
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  cancelled,
  partiallyRefunded,
  refunded;

  String get label => switch (this) {
    pending => l10n.paymentPending,
    completed => l10n.paymentPaid,
    failed => l10n.paymentFailed,
    cancelled => l10n.paymentCancelled,
    partiallyRefunded => l10n.paymentPartiallyRefunded,
    refunded => l10n.paymentRefunded,
  };
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
  tablesAssigned,
}
