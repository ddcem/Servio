import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _money = NumberFormat('#,##0.00', 'en_US');
  static final _dateTime = DateFormat('dd.MM.yyyy HH:mm');
  static final _date = DateFormat('dd.MM.yyyy');
  static final _time = DateFormat('HH:mm');

  static String money(double amount, String symbol) => '$symbol${_money.format(amount)}';

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String date(DateTime value) => _date.format(value);

  static String time(DateTime value) => _time.format(value);

  static String percent(double value) => '${(value * 100).round()}%';

  /// "3m", "1h 05m" – used for ticket waiting times.
  static String elapsed(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) return '${minutes < 0 ? 0 : minutes}m';
    return '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';
  }

  /// "just now", "5 min ago", "yesterday 14:20" – used in notification lists.
  static String relative(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24 && DateTime.now().day == value.day) return 'today ${time(value)}';
    return dateTime(value);
  }
}
