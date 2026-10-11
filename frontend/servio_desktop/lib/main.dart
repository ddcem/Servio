import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

/// The API address is set at build time: flutter run --dart-define=API_BASE_URL=http://localhost:5050
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:5050');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final api = ApiClient(apiBaseUrl);
  final realtime = RealtimeService(api.baseUrl);
  final auth = AuthProvider(api, realtime);
  final language = LanguageController(preferences, api, auth);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: realtime),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: language),
        ChangeNotifierProvider(create: (_) => NotificationCenter(NotificationProvider(api), realtime)),
        Provider(create: (_) => MenuItemProvider(api)),
        Provider(create: (_) => MenuCategoryProvider(api)),
        Provider(create: (_) => ItemTagProvider(api)),
        Provider(create: (_) => TableAreaProvider(api)),
        Provider(create: (_) => CurrencyProvider(api)),
        Provider(create: (_) => RoleProvider(api)),
        Provider(create: (_) => PreparationStationProvider(api)),
        Provider(create: (_) => PaymentMethodProvider(api)),
        Provider(create: (_) => UserProvider(api)),
        Provider(create: (_) => RestaurantTableProvider(api)),
        Provider(create: (_) => ReservationProvider(api)),
        Provider(create: (_) => OrderProvider(api)),
        Provider(create: (_) => OrderTicketProvider(api)),
        Provider(create: (_) => PaymentProvider(api)),
        Provider(create: (_) => NotificationProvider(api)),
        Provider(create: (_) => SettingsProvider(api)),
        Provider(create: (_) => ReportProvider(api)),
      ],
      child: const ServioDesktopApp(),
    ),
  );
}
