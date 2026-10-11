import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';

import 'screens/admin_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/station/station_display_screen.dart';

class ServioDesktopApp extends StatefulWidget {
  const ServioDesktopApp({super.key});

  @override
  State<ServioDesktopApp> createState() => _ServioDesktopAppState();
}

class _ServioDesktopAppState extends State<ServioDesktopApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AuthProvider _auth = context.read<AuthProvider>();

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
  Widget build(BuildContext context) => MaterialApp(
    title: 'Servio',
    debugShowCheckedModeBanner: false,
    locale: context.watch<LanguageController>().locale,
    supportedLocales: LanguageController.supportedLocales,
    localizationsDelegates: ServioLocalizations.localizationsDelegates,
    navigatorKey: _navigatorKey,
    theme: ServioTheme.light(),
    home: Consumer<AuthProvider>(
      builder: (context, auth, _) => switch (auth.user?.role) {
        null => const LoginScreen(),
        Roles.kitchen => const StationDisplayScreen(station: Stations.kitchen),
        Roles.bar => const StationDisplayScreen(station: Stations.bar),
        _ => const AdminHomeScreen(),
      },
    ),
  );
}
