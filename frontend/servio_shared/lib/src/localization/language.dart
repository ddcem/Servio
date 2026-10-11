import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../auth/auth_provider.dart';
import '../l10n/servio_localizations.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../utils/formatters.dart';

ServioLocalizations _current = lookupServioLocalizations(const Locale('en'));

/// The texts in the language the user chose. The whole app rebuilds when the language changes,
/// so this can be read anywhere, including validators and status labels.
ServioLocalizations get l10n => _current;

/// The app language. The choice is remembered on the device (for the login screen) and saved in the
/// user's account, so the server writes errors, notifications, emails and PDFs in it as well.
class LanguageController extends ChangeNotifier {
  LanguageController(this._preferences, this._api, this._auth) {
    _code = normalize(_preferences.getString(_storageKey) ?? PlatformDispatcher.instance.locale.languageCode);
    _apply();
    _auth.addListener(_onAuthChanged);
  }

  static const supportedLocales = [Locale('en'), Locale('bs')];

  /// Each language is shown in its own name, so it can be found by someone who does not read the current one.
  static const names = {'en': 'English', 'bs': 'Bosanski'};

  static const _storageKey = 'language';

  final SharedPreferences _preferences;
  final ApiClient _api;
  final AuthProvider _auth;

  late String _code;
  bool _chosenBeforeLogin = false;
  int? _syncedUserId;

  String get code => _code;
  Locale get locale => Locale(_code);

  /// "bs-BA", "hr" → "bs"; anything else → "en".
  static String normalize(String? code) => switch (code?.toLowerCase().split(RegExp('[-_]')).first) {
    'bs' || 'hr' || 'sr' => 'bs',
    _ => 'en',
  };

  /// Switches the app language and saves it in the account when someone is logged in.
  Future<void> select(String code) async {
    final language = normalize(code);
    if (_auth.user == null) {
      // An explicit choice on the login screen wins over the account's saved language, even when it is
      // already shown (the device remembers the previous user's language).
      _chosenBeforeLogin = true;
      if (language != _code) _set(language);
      return;
    }
    if (language == _code) return;
    _set(language);
    _auth.updateUser(await ProfileProvider(_api).setLanguage(language));
  }

  /// After login the account's language applies, unless the user just picked one on the login screen;
  /// then that choice is saved to the account.
  void _onAuthChanged() {
    final user = _auth.user;
    if (user == null) {
      _syncedUserId = null;
      return;
    }
    if (_syncedUserId == user.id) return;
    _syncedUserId = user.id;

    if (_chosenBeforeLogin && user.preferredLanguage != _code) {
      _saveToAccount(user);
    } else if (user.preferredLanguage != _code) {
      _set(user.preferredLanguage);
    }
    _chosenBeforeLogin = false;
  }

  Future<void> _saveToAccount(User user) async {
    try {
      _auth.updateUser(await ProfileProvider(_api).setLanguage(_code));
    } catch (_) {
      // Not critical: the app already shows the chosen language; the next change saves it again.
    }
  }

  void _set(String language) {
    _code = normalize(language);
    _apply();
    _preferences.setString(_storageKey, _code);
    notifyListeners();
    _rebuildOpenScreens();
  }

  /// Texts are read through [l10n], which widgets do not subscribe to, so screens that are already open
  /// (e.g. below the settings screen) are redrawn once to show the new language.
  static void _rebuildOpenScreens() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void rebuild(Element element) {
        element.markNeedsBuild();
        element.visitChildren(rebuild);
      }

      WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
    });
  }

  void _apply() {
    _current = lookupServioLocalizations(locale);
    _api.language = _code;
    Formatters.language = _code;
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
