import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import '../localization/language.dart';

/// Thin wrapper over HTTP that adds the bearer token, encodes JSON and turns
/// error responses into [ApiException]s with the server's message.
class ApiClient {
  ApiClient(String baseUrl) : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  final String baseUrl;
  final http.Client _http = http.Client();

  /// The bearer token of the logged-in user, or null.
  String? token;

  /// Two-letter code of the app language; the server answers in it.
  String language = 'en';

  /// Called when the server rejects the token (expired or logged out elsewhere).
  void Function()? onUnauthorized;

  Map<String, String> get authHeaders => {if (token != null) 'Authorization': 'Bearer $token', 'Accept-Language': language};

  Uri uri(String path, [Map<String, dynamic>? query]) {
    final parameters = <String, dynamic>{};
    query?.forEach((key, value) {
      if (value == null || (value is String && value.trim().isEmpty)) return;
      parameters[key] = value is Iterable ? value.map((e) => '$e').toList() : '$value';
    });
    return Uri.parse('$baseUrl/api/$path').replace(queryParameters: parameters.isEmpty ? null : parameters);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _http.get(uri(path, query), headers: _headers()));

  Future<dynamic> post(String path, [Object? body]) =>
      _send(() => _http.post(uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body)));

  Future<dynamic> put(String path, [Object? body]) =>
      _send(() => _http.put(uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body)));

  Future<dynamic> delete(String path) => _send(() => _http.delete(uri(path), headers: _headers()));

  Future<Uint8List> getBytes(String path, {Map<String, dynamic>? query}) async {
    final response = await _execute(() => _http.get(uri(path, query), headers: authHeaders));
    return response.bodyBytes;
  }

  Future<void> putFile(String path, Uint8List bytes, String fileName) async {
    final request = http.MultipartRequest('PUT', uri(path))
      ..headers.addAll(authHeaders)
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));
    await _execute(() async => http.Response.fromStream(await _http.send(request)));
  }

  Map<String, String> _headers() => {...authHeaders, 'Content-Type': 'application/json; charset=utf-8'};

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    final response = await _execute(request);
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<http.Response> _execute(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request();
    } on SocketException {
      throw ApiException(l10n.serverUnreachable(baseUrl));
    } on http.ClientException {
      throw ApiException(l10n.serverUnreachable(baseUrl));
    }

    if (response.statusCode >= 200 && response.statusCode < 300) return response;

    final exception = ApiException.fromResponse(response);
    if (exception.isUnauthorized && token != null) {
      onUnauthorized?.call();
    }
    throw exception;
  }
}
