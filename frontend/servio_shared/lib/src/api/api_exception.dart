import 'dart:convert';

import 'package:http/http.dart' as http;

import '../localization/language.dart';

/// An error returned by the Servio API, carrying the message meant for the user
/// and, for validation errors, the message of every invalid field.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, Map<String, List<String>>? fieldErrors}) : fieldErrors = fieldErrors ?? const {};

  factory ApiException.fromResponse(http.Response response) {
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final errors = (body['errors'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, (value as List).cast<String>()),
      );
      return ApiException(
        body['message'] as String? ?? _fallbackMessage(response.statusCode),
        statusCode: response.statusCode,
        fieldErrors: errors,
      );
    } on FormatException {
      return ApiException(_fallbackMessage(response.statusCode), statusCode: response.statusCode);
    }
  }

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  /// The first validation message for [field] (matched case-insensitively), or null.
  String? errorFor(String field) {
    final key = fieldErrors.keys.firstWhere((k) => k.toLowerCase() == field.toLowerCase(), orElse: () => '');
    return key.isEmpty ? null : fieldErrors[key]!.first;
  }

  static String _fallbackMessage(int statusCode) => switch (statusCode) {
    401 => l10n.sessionExpired,
    403 => l10n.errorForbidden,
    404 => l10n.errorNotFound,
    _ => l10n.errorServer,
  };

  @override
  String toString() => message;
}
