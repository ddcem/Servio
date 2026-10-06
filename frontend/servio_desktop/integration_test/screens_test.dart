import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:servio_desktop/main.dart' as app;

Future<void> shot(WidgetTester tester, String name) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 300));
  await Future<void>.delayed(const Duration(milliseconds: 1200));
  await tester.pumpAndSettle();
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final image = await layer.toImage(Offset.zero & (view.size * view.flutterView.devicePixelRatio));
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${Directory.systemTemp.path}/servio_$name.png');
  await file.writeAsBytes(data!.buffer.asUint8List());
  // ignore: avoid_print
  print('SHOT ${file.path}');
}

Future<void> waitFor(WidgetTester tester, Finder finder, {int seconds = 15}) async {
  for (var i = 0; i < seconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  await shot(tester, 'failure');
  throw TestFailure('Timed out waiting for $finder');
}

final _sidebar = find.byType(Scrollable).first;

/// Scrolls the admin sidebar to [label] and opens that section.
Future<void> openSection(WidgetTester tester, String label) async {
  final item = find.descendant(of: _sidebar, matching: find.text(label));
  await tester.drag(_sidebar, const Offset(0, 2000));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(item, 60, scrollable: _sidebar);
  await tester.ensureVisible(item);
  await tester.pumpAndSettle();
  await tester.tap(item);
}

Future<void> login(WidgetTester tester, String user) async {
  await tester.enterText(find.byType(TextFormField).at(0), user);
  await tester.enterText(find.byType(TextFormField).at(1), 'test');
  await tester.tap(find.text('Login'));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('admin screens', (tester) async {
    app.main();
    await waitFor(tester, find.text('Staff Login'));
    await shot(tester, '01_login');

    await login(tester, 'desktop');
    await waitFor(tester, find.text('Admin Dashboard'));
    await shot(tester, '02_admin_home');

    await tester.tap(find.text('Kitchen View'));
    await waitFor(tester, find.textContaining('active order'));
    await shot(tester, '03_kitchen_view_only');
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Admin Panel'));
    await waitFor(tester, find.text('Menu Management'));
    await waitFor(tester, find.text('Aperol Spritz'));
    await shot(tester, '04_menu');

    for (final (label, wait, name) in [
      ('Employees', 'Add Employee', '05_employees'),
      ('Tables', 'Add Table', '06_tables'),
      ('Reservations', 'New Reservation', '07_reservations'),
      ('Orders & Payments', 'ORDER', '08_orders'),
      ('Reference Data', 'Add category', '09_reference'),
      ('Reports', 'Popular items today', '10_reports'),
      ('Notifications', 'Mark all as read', '11_notifications'),
      ('Settings', 'General Settings', '12_settings'),
    ]) {
      await openSection(tester, label);
      await waitFor(tester, find.text(wait));
      await shot(tester, name);
    }

    await openSection(tester, 'Menu Management');
    await waitFor(tester, find.text('Aperol Spritz'));
    await tester.tap(find.text('Add Item'));
    await waitFor(tester, find.text('Add menu item'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await shot(tester, '13_menu_form_validation');
  });
}
