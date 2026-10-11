import 'package:intl/intl.dart';

import '../localization/language.dart';

abstract final class Formatters {
  /// Set by the language controller: amounts are "€1,234.50" in English and "1.234,50 €" in Bosnian.
  static String language = 'en';

  static final _money = NumberFormat('#,##0.00', 'en_US');
  static final _dateTime = DateFormat('dd.MM.yyyy HH:mm');
  static final _date = DateFormat('dd.MM.yyyy');
  static final _time = DateFormat('HH:mm');

  static String money(double amount, String symbol) {
    final number = _money.format(amount);
    if (language != 'bs') return '$symbol$number';
    // 1,234.50 → 1.234,50
    final bosnian = number.replaceAll(',', '\u0000').replaceAll('.', ',').replaceAll('\u0000', '.');
    return '$bosnian $symbol';
  }

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String date(DateTime value) => _date.format(value);

  static String time(DateTime value) => _time.format(value);

  /// "12.5" in English, "12,5" in Bosnian.
  static String decimal(double value, {int digits = 1}) {
    final text = value.toStringAsFixed(digits);
    return language == 'bs' ? text.replaceAll('.', ',') : text;
  }

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
    if (difference.inMinutes < 1) return l10n.justNow;
    if (difference.inMinutes < 60) return l10n.minutesAgo(difference.inMinutes);
    if (difference.inHours < 24 && DateTime.now().day == value.day) return l10n.todayAt(time(value));
    return dateTime(value);
  }
}
