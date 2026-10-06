import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/tables_screen.dart';

class ServioMobileApp extends StatefulWidget {
  const ServioMobileApp({super.key});

  @override
  State<ServioMobileApp> createState() => _ServioMobileAppState();
}

class _ServioMobileAppState extends State<ServioMobileApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthProvider _auth = context.read<AuthProvider>();
  late bool _guideSeen = context.read<SharedPreferences>().getBool(OnboardingScreen.seenKey) ?? false;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  /// After logout or an expired session every open screen is closed, so the login screen is on top.
  void _onAuthChanged() {
    if (!_auth.isLoggedIn) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      context.read<NotificationCenter>().reset();
    }
  }

  @override
  Widget build(BuildContext _) => MaterialApp(
    title: 'Servio',
    debugShowCheckedModeBanner: false,
    navigatorKey: _navigatorKey,
    theme: ServioTheme.light(),
    home: !_guideSeen
        ? OnboardingScreen(onDone: () => setState(() => _guideSeen = true))
        : Consumer<AuthProvider>(builder: (context, auth, _) => auth.isLoggedIn ? const TablesScreen() : const LoginScreen()),
  );
}
