import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:servio_shared/servio_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

/// The API address is set at build time. 10.0.2.2 is the host machine as seen from the Android emulator:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5050
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:5050');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final api = ApiClient(apiBaseUrl);
  final realtime = RealtimeService(api.baseUrl);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: realtime),
        Provider.value(value: preferences),
        ChangeNotifierProvider(create: (_) => AuthProvider(api, realtime)),
        ChangeNotifierProvider(create: (_) => NotificationCenter(NotificationProvider(api), realtime)),
        Provider(create: (_) => MenuItemProvider(api)),
        Provider(create: (_) => MenuCategoryProvider(api)),
        Provider(create: (_) => RestaurantTableProvider(api)),
        Provider(create: (_) => OrderProvider(api)),
        Provider(create: (_) => OrderTicketProvider(api)),
        Provider(create: (_) => PaymentProvider(api)),
        Provider(create: (_) => NotificationProvider(api)),
        Provider(create: (_) => SettingsProvider(api)),
        Provider(create: (_) => ProfileProvider(api)),
      ],
      child: const ServioMobileApp(),
    ),
  );
}
