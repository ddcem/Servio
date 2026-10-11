import '../localization/language.dart';

/// Client-side checks that mirror the API's validation rules, with the same messages.
/// The API validates again; its messages are shown under the fields as well.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9][0-9 /-]{5,18}$');
  static final _username = RegExp(r'^[a-zA-Z0-9._]{3,50}$');
  static final _password = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,100}$');

  static String? required(String? value, String label) =>
      value == null || value.trim().isEmpty ? l10n.fieldRequired(label) : null;

  static String? length(String? value, String label, {int min = 0, required int max, bool isRequired = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? l10n.fieldRequired(label) : null;
    if (text.length < min || text.length > max) {
      return min > 0 ? l10n.fieldLengthBetween(label, min, max) : l10n.fieldLengthMax(label, max);
    }
    return null;
  }

  static String? email(String? value, {bool isRequired = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? l10n.emailRequired : null;
    return _email.hasMatch(text) ? null : l10n.emailInvalid;
  }

  static String? phone(String? value, {bool isRequired = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? l10n.phoneRequired : null;
    return _phone.hasMatch(text) ? null : l10n.phoneInvalid;
  }

  static String? username(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.usernameRequired;
    return _username.hasMatch(text) ? null : l10n.usernameInvalid;
  }

  static String? newPassword(String? value, {bool isRequired = true}) {
    final text = value ?? '';
    if (text.isEmpty) return isRequired ? l10n.passwordRequired : null;
    return _password.hasMatch(text) ? null : l10n.passwordInvalid;
  }

  static String? confirmation(String? value, String password) => (value ?? '') == password ? null : l10n.passwordsDoNotMatch;

  static String? decimal(String? value, String label, {required double min, required double max}) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (text.isEmpty) return l10n.fieldRequired(label);
    final number = double.tryParse(text);
    if (number == null) return l10n.numberInvalid(label);
    if (number < min || number > max) return l10n.numberBetween(label, _plain(min), _plain(max));
    return null;
  }

  static String? integer(String? value, String label, {required int min, required int max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return l10n.fieldRequired(label);
    final number = int.tryParse(text);
    if (number == null) return l10n.wholeNumberInvalid(label);
    if (number < min || number > max) return l10n.numberBetween(label, '$min', '$max');
    return null;
  }

  static double parseDecimal(String text) => double.parse(text.trim().replaceAll(',', '.'));

  static String _plain(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);
}
