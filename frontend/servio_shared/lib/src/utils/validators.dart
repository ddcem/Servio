/// Client-side checks that mirror the API's validation rules, with the same messages.
/// The API validates again; its messages are shown under the fields as well.
abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final _phone = RegExp(r'^\+?[0-9][0-9 /-]{5,18}$');
  static final _username = RegExp(r'^[a-zA-Z0-9._]{3,50}$');
  static final _password = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,100}$');

  static String? required(String? value, String label) => value == null || value.trim().isEmpty ? '$label is required.' : null;

  static String? length(String? value, String label, {int min = 0, required int max, bool isRequired = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? '$label is required.' : null;
    if (text.length < min || text.length > max) {
      return min > 0 ? '$label must be between $min and $max characters long.' : '$label can be at most $max characters long.';
    }
    return null;
  }

  static String? email(String? value, {bool isRequired = true}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? 'Email is required.' : null;
    return _email.hasMatch(text) ? null : 'Enter a valid email address, e.g. name@example.com.';
  }

  static String? phone(String? value, {bool isRequired = false}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return isRequired ? 'Phone number is required.' : null;
    return _phone.hasMatch(text)
        ? null
        : 'Enter a phone number with 6 to 19 digits, optionally starting with +, e.g. +387 61 123 456.';
  }

  static String? username(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Username is required.';
    return _username.hasMatch(text)
        ? null
        : 'Username must be 3 to 50 characters and may contain only letters, digits, dots and underscores.';
  }

  static String? newPassword(String? value, {bool isRequired = true}) {
    final text = value ?? '';
    if (text.isEmpty) return isRequired ? 'Password is required.' : null;
    return _password.hasMatch(text)
        ? null
        : 'Password must be 8 to 100 characters long and contain at least one letter and one digit.';
  }

  static String? confirmation(String? value, String password) => (value ?? '') == password ? null : 'Passwords do not match.';

  static String? decimal(String? value, String label, {required double min, required double max}) {
    final text = value?.trim().replaceAll(',', '.') ?? '';
    if (text.isEmpty) return '$label is required.';
    final number = double.tryParse(text);
    if (number == null) return '$label must be a number, e.g. 12.50.';
    if (number < min || number > max) return '$label must be between ${_plain(min)} and ${_plain(max)}.';
    return null;
  }

  static String? integer(String? value, String label, {required int min, required int max}) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label is required.';
    final number = int.tryParse(text);
    if (number == null) return '$label must be a whole number.';
    if (number < min || number > max) return '$label must be between $min and $max.';
    return null;
  }

  static double parseDecimal(String text) => double.parse(text.trim().replaceAll(',', '.'));

  static String _plain(double value) => value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(2);
}
