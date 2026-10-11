import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:servio_mobile/main.dart' as app;
import 'package:servio_shared/servio_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prints the screen as base64 PNG lines (`SHOT:name:chunk`), which the host reassembles,
/// because the app and its files are removed from the device when the test ends.
Future<void> shot(WidgetTester tester, String name) async {
  await settle(tester);
  await Future<void>.delayed(const Duration(milliseconds: 1200));
  await settle(tester);
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final ratio = view.flutterView.devicePixelRatio;
  final image = await layer.toImage(Offset.zero & (view.size * ratio), pixelRatio: 1.5 / ratio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final encoded = base64Encode(data!.buffer.asUint8List());
  for (var i = 0; i < encoded.length; i += 700) {
    // ignore: avoid_print
    print('SHOT:$name:${encoded.substring(i, i + 700 > encoded.length ? encoded.length : i + 700)}');
  }
  // ignore: avoid_print
  print('SHOT:$name:END');
}

/// Waits for animations, but gives up after a few seconds: spinners never settle.
Future<void> settle(WidgetTester tester) async {
  try {
    await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 5));
  } on FlutterError {
    // Still animating (e.g. a progress indicator); take the screen as it is.
  }
}

Future<void> waitFor(WidgetTester tester, Finder finder, {int seconds = 20}) async {
  for (var i = 0; i < seconds * 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  await shot(tester, 'failure');
  throw TestFailure('Timed out waiting for $finder');
}

/// tester.pageBack() looks for the English "Back" tooltip, so the back arrow is found by type.
Future<void> goBack(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).last);
  await settle(tester);
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Switches to Bosnian on the login screen (saved to the account at login), goes through the main screens,
  /// then switches back to English in Settings. Nothing is ordered.
  testWidgets('language switching', (tester) async {
    SharedPreferences.setMockInitialValues({'waiter_guide_seen': true, 'language': 'en'});
    app.main();

    await waitFor(tester, find.text('Waiter Login'));
    await tapAndSettle(tester, find.byType(LanguageMenuButton));
    await tapAndSettle(tester, find.text('Bosanski').last);
    await waitFor(tester, find.text('Prijava konobara'));
    await tester.enterText(find.byType(TextFormField).at(0), 'mobile');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await shot(tester, 'bs01_login');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Prijava'));

    await waitFor(tester, find.text('Status stolova'));
    await waitFor(tester, find.text('SLOB'));
    await shot(tester, 'bs02_tables');

    await tapAndSettle(tester, find.text('SLOB').first);
    await waitFor(tester, find.text('Koliko gostiju?'));
    await shot(tester, 'bs03_guests');
    await tapAndSettle(tester, find.text('Započni narudžbu'));

    await waitFor(tester, find.text('Favoriti'));
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, 'bs04_menu');
    await tapAndSettle(tester, find.text('Main Course').last);
    await waitFor(tester, find.text('Ribeye Steak'));
    await tapAndSettle(tester, find.text('Ribeye Steak'));
    await waitFor(tester, find.text('Prijedlog za dodatnu prodaju'));
    await shot(tester, 'bs05_upsell');
    await tapAndSettle(tester, find.text('Ne sada'));
    await tapAndSettle(tester, find.byTooltip('Trenutna narudžba'));
    await waitFor(tester, find.text('Pošalji narudžbu'));
    await shot(tester, 'bs06_cart');
    await tapAndSettle(tester, find.text('Obriši sve'));
    await settle(tester);
    await shot(tester, 'bs06a_cart_cleared');
    await tapAndSettle(tester, find.byTooltip('Zatvori'));
    await settle(tester);
    await shot(tester, 'bs06b_after_close');
    await goBack(tester);

    await waitFor(tester, find.text('ZAU'));
    final grid = find.byType(CustomScrollView);
    await tapAndSettle(tester, find.descendant(of: grid, matching: find.text('ZAU')).first);
    await waitFor(tester, find.text('Dodaj artikle'));
    await shot(tester, 'bs07_table_order');
    await tapAndSettle(tester, find.text('Plaćanje').last);
    await waitFor(tester, find.text('Naplata'));
    await tapAndSettle(tester, find.text('10%'));
    await tapAndSettle(tester, find.text('Gotovina'));
    await shot(tester, 'bs08_payment');
    await goBack(tester);
    await goBack(tester);

    await tapAndSettle(tester, find.byTooltip('Obavijesti'));
    await waitFor(tester, find.text('Nepročitano'));
    await shot(tester, 'bs09_notifications');
    await goBack(tester);

    await tapAndSettle(tester, find.byTooltip('Više'));
    await tapAndSettle(tester, find.text('Postavke'));
    await waitFor(tester, find.text('Jezik'));
    await shot(tester, 'bs10_settings');

    // Back to English: Settings and the tables screen underneath must both switch.
    await tapAndSettle(tester, find.text('English'));
    await waitFor(tester, find.text('Language'));
    await shot(tester, 'bs11_settings_english');
    await goBack(tester);
    await waitFor(tester, find.text('Welcome, John'));
    await shot(tester, 'bs12_tables_english');
    expect(LanguageController.normalize(l10n.localeName), 'en');
  });
}
