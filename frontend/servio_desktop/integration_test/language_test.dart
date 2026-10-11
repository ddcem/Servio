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

  /// Picks Bosnian on the login screen, visits every admin section and the kitchen display,
  /// then switches back to English in the admin settings.
  testWidgets('admin screens in Bosnian', (tester) async {
    app.main();
    await waitFor(tester, find.byType(LanguageMenuButton));
    await tester.tap(find.byType(LanguageMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bosanski').last);
    await waitFor(tester, find.text('Prijava osoblja'));
    await shot(tester, 'bs01_login');

    await tester.enterText(find.byType(TextFormField).at(0), 'desktop');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await tester.tap(find.widgetWithText(FilledButton, 'Prijava'));
    await waitFor(tester, find.text('Administratorska ploča'));
    await shot(tester, 'bs02_home');

    await tester.tap(find.text('Pregled kuhinje'));
    await waitFor(tester, find.text('Ekran kuhinje'));
    await shot(tester, 'bs03_kitchen');
    await tester.tap(find.byTooltip('Nazad'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Administracija'));
    await waitFor(tester, find.text('Upravljanje menijem'));
    await waitFor(tester, find.text('Aperol Spritz'));
    await shot(tester, 'bs04_menu');

    for (final (label, wait, name) in [
      ('Uposlenici', 'Dodaj uposlenika', 'bs05_employees'),
      ('Stolovi', 'Dodaj sto', 'bs06_tables'),
      ('Rezervacije', 'Nova rezervacija', 'bs07_reservations'),
      ('Narudžbe i plaćanja', 'NARUDŽBA', 'bs08_orders'),
      ('Šifarnici', 'Dodaj kategoriju', 'bs09_reference'),
      ('Izvještaji', 'Današnji najpopularniji artikli', 'bs10_reports'),
      ('Obavijesti', 'Označi sve kao pročitano', 'bs11_notifications'),
      ('Postavke', 'Moje postavke', 'bs12_settings'),
    ]) {
      await openSection(tester, label);
      await waitFor(tester, find.text(wait));
      await shot(tester, name);
    }

    await openSection(tester, 'Narudžbe i plaćanja');
    await waitFor(tester, find.text('NARUDŽBA'));
    await tester.tap(find.text('Plaćeno').first);
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('Plaćanja'));
    await shot(tester, 'bs13_order_details');
    await tester.tap(find.byTooltip('Zatvori').last);
    await tester.pumpAndSettle();

    await openSection(tester, 'Postavke');
    await waitFor(tester, find.text('Moje postavke'));
    await tester.tap(find.text('English'));
    await waitFor(tester, find.text('My preferences'));
    await waitFor(tester, find.text('Menu Management'));
    await shot(tester, 'bs14_back_to_english');
  });
}
