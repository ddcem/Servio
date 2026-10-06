import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:servio_mobile/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

/// Walks through the waiter's day against the running API and saves a screenshot of every screen.
/// The order it creates is cancelled at the end.
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

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('waiter flow', (tester) async {
    SharedPreferences.setMockInitialValues({});
    (await SharedPreferences.getInstance()).clear();
    app.main();

    await waitFor(tester, find.text('Select Tables'));
    await shot(tester, '01_guide');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await shot(tester, '02_guide_menu');
    await tester.tap(find.text('Skip'));

    await waitFor(tester, find.text('Waiter Login'));
    await tester.enterText(find.byType(TextFormField).at(0), 'mobile');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await shot(tester, '03_login');
    await tapAndSettle(tester, find.text('Login'));

    await waitFor(tester, find.text('Table Status'));
    await waitFor(tester, find.text('AVAIL'));
    await shot(tester, '04_tables');

    await tapAndSettle(tester, find.text('AVAIL').first);
    await waitFor(tester, find.text('How many guests?'));
    await shot(tester, '05_guests');
    await tapAndSettle(tester, find.text('Start order'));

    await waitFor(tester, find.text('Favorites'));
    final tableTitle = tester.widget<Text>(find.textContaining(RegExp(r'^Table \d+$')).first).data!;
    final tableNumber = tableTitle.split(' ').last;
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, '06_menu_favorites');

    await tapAndSettle(tester, find.text('Main Course').last);
    await waitFor(tester, find.text('Ribeye Steak'));
    await shot(tester, '07_menu_main_course');
    await tapAndSettle(tester, find.text('Ribeye Steak'));
    await waitFor(tester, find.text('Upsell Suggestion'));
    await shot(tester, '08_upsell');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Add').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tapAndSettle(tester, find.byTooltip('Current order'));
    await waitFor(tester, find.text('Send Order'));
    await shot(tester, '09_cart');
    await tapAndSettle(tester, find.text('Send Order'));

    await waitFor(tester, find.text('OCC'));
    await tester.pump(const Duration(seconds: 2));
    await shot(tester, '10_tables_after_order');

    await tapAndSettle(tester, find.byTooltip('My active tables'));
    await waitFor(tester, find.text('Active Tables'));
    await waitFor(tester, find.text('Payment'));
    await shot(tester, '11_active_tables');

    await tapAndSettle(tester, find.text('Payment').first);
    await waitFor(tester, find.text('Process Payment'));
    await tapAndSettle(tester, find.text('15%'));
    await tapAndSettle(tester, find.text('Cash'));
    await tapAndSettle(tester, find.text('5'));
    await tapAndSettle(tester, find.text('0'));
    await shot(tester, '12_payment_cash');
    await tapAndSettle(tester, find.text('Card'));
    await shot(tester, '13_payment_card');

    // Back to the tables; cancel the order this test created, so it leaves no data behind.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await waitFor(tester, find.text('OCC'));
    final grid = find.byType(CustomScrollView);
    final card = find.descendant(of: grid, matching: find.text(tableNumber)).first;
    await tester.scrollUntilVisible(card, -300, scrollable: find.descendant(of: grid, matching: find.byType(Scrollable)).first);
    await tapAndSettle(tester, card);
    await waitFor(tester, find.text('Add Items'));
    await shot(tester, '14_table_order');
    await tapAndSettle(tester, find.byTooltip('More'));
    await tapAndSettle(tester, find.text('Cancel order'));
    await waitFor(tester, find.text('Reason'));
    await tester.enterText(find.byType(TextFormField), 'Created by an automated app test');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Cancel order'));
    await waitFor(tester, find.text('The order was cancelled.'));
    await shot(tester, '15_cancelled');

    await tapAndSettle(tester, find.byTooltip('Notifications'));
    await waitFor(tester, find.text('Unread'));
    await shot(tester, '16_notifications');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byTooltip('More'));
    await tapAndSettle(tester, find.text('My profile'));
    await waitFor(tester, find.text('Save changes'));
    await shot(tester, '17_profile');
  });
}
