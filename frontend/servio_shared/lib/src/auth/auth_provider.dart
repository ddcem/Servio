import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_exception.dart';
import '../models/user.dart';
import '../realtime/realtime_service.dart';

/// Holds the logged-in user. The token lives only in memory: closing the app logs out.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this.api, this.realtime) {
    api.onUnauthorized = _expireSession;
  }

  final ApiClient api;
  final RealtimeService realtime;

  User? _user;
  String? _sessionMessage;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Why the user was sent back to the login screen (e.g. the session expired), shown once.
  String? takeSessionMessage() {
    final message = _sessionMessage;
    _sessionMessage = null;
    return message;
  }

  bool hasRole(String role) => _user?.role == role;

  /// Logs in and checks that the role may use this app; [allowedRoles] is empty for any role.
  Future<void> login(String username, String password, {Set<String> allowedRoles = const {}}) async {
    final json = await api.post('auth/login', {'username': username.trim(), 'password': password}) as Map<String, dynamic>;
    final user = User.fromJson(json['user'] as Map<String, dynamic>);
    api.token = json['token'] as String;

    if (allowedRoles.isNotEmpty && !allowedRoles.contains(user.role)) {
      await _logoutOnServer();
      api.token = null;
      throw ApiException('The ${user.role.toLowerCase()} account cannot use this app.');
    }

    _user = user;
    notifyListeners();
    await realtime.connect(api.token!);
  }

  Future<void> logout() async {
    await _logoutOnServer();
    await _clear();
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> _logoutOnServer() async {
    try {
      await api.post('auth/logout');
    } on ApiException {
      // The session is cleared locally either way.
    }
  }

  void _expireSession() {
    _sessionMessage = 'Your session has expired. Please log in again.';
    _clear();
  }

  Future<void> _clear() async {
    api.token = null;
    _user = null;
    notifyListeners();
    await realtime.disconnect();
  }
}
