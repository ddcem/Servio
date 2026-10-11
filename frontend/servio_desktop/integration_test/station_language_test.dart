import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:servio_desktop/main.dart' as app;
import 'package:servio_shared/servio_shared.dart';

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

  /// Kitchen staff change the language from the account menu of their display.
  testWidgets('kitchen display language', (tester) async {
    app.main();
    await waitFor(tester, find.byType(LanguageMenuButton));
    await tester.tap(find.byType(LanguageMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await waitFor(tester, find.text('Staff Login'));
    await tester.enterText(find.byType(TextFormField).at(0), 'kitchen');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await tester.tap(find.widgetWithText(FilledButton, 'Login'));
    await waitFor(tester, find.text('Kitchen Display'));

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await shot(tester, 'k01_settings_dialog');
    await tester.tap(find.text('Bosanski'));
    await waitFor(tester, find.text('Ekran kuhinje'));
    await shot(tester, 'k02_settings_dialog_bs');
    await tester.tap(find.text('Zatvori'));
    await tester.pumpAndSettle();
    await shot(tester, 'k03_display_bs');

    await tester.tap(find.byTooltip('Korisnički račun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Postavke'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await waitFor(tester, find.text('Kitchen Display'));
  });
}
