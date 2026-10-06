/// Role names as defined by the API.
abstract final class Roles {
  static const admin = 'Admin';
  static const waiter = 'Waiter';
  static const kitchen = 'Kitchen';
  static const bar = 'Bar';
}

/// Preparation station names; Kitchen and Bar users work at the station with their role's name.
abstract final class Stations {
  static const kitchen = 'Kitchen';
  static const bar = 'Bar';
}
