import '../localization/language.dart';

/// Role names as defined by the API.
abstract final class Roles {
  static const admin = 'Admin';
  static const waiter = 'Waiter';
  static const kitchen = 'Kitchen';
  static const bar = 'Bar';

  /// The role's name in the user's language.
  static String label(String role) => switch (role) {
    admin => l10n.roleAdmin,
    waiter => l10n.roleWaiter,
    kitchen => l10n.roleKitchen,
    bar => l10n.roleBar,
    _ => role,
  };
}

/// Preparation station names; Kitchen and Bar users work at the station with their role's name.
abstract final class Stations {
  static const kitchen = 'Kitchen';
  static const bar = 'Bar';

  static String label(String station) => Roles.label(station);
}

/// Payment method names as defined by the API.
abstract final class PaymentMethods {
  static const cash = 'Cash';
  static const payPal = 'PayPal';

  static String label(String method) => method == cash ? l10n.methodCash : method;
}
