import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:servio_mobile/main.dart' as app;
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

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await settle(tester);
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Adds a note to a cart item, then discards the round; nothing is sent to the server.
  testWidgets('cart item note', (tester) async {
    SharedPreferences.setMockInitialValues({'waiter_guide_seen': true});
    app.main();

    await waitFor(tester, find.text('Waiter Login'));
    await tester.enterText(find.byType(TextFormField).at(0), 'mobile');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await tapAndSettle(tester, find.text('Login'));
    await waitFor(tester, find.text('AVAIL'));
    await tapAndSettle(tester, find.text('AVAIL').first);
    await tapAndSettle(tester, find.text('Start order'));

    await waitFor(tester, find.text('Main Course'));
    await tapAndSettle(tester, find.text('Main Course').last);
    await waitFor(tester, find.text('Beef Burger'));
    await tapAndSettle(tester, find.text('Beef Burger'));
    await tester.pump(const Duration(seconds: 2));
    if (find.text('Not Now').evaluate().isNotEmpty) await tapAndSettle(tester, find.text('Not Now'));

    await tapAndSettle(tester, find.byTooltip('Current order'));
    await waitFor(tester, find.text('Add note'));
    await tapAndSettle(tester, find.text('Add note'));
    await waitFor(tester, find.text('Note for Beef Burger'));
    await tester.enterText(find.byType(TextField).last, 'No onions, well done');
    await tapAndSettle(tester, find.text('Save'));
    await settle(tester);
    await waitFor(tester, find.text('No onions, well done'));
    await shot(tester, 'n01_note_saved');

    // Edit it once more, then cancel the dialog: the note must stay.
    await tapAndSettle(tester, find.text('No onions, well done'));
    await waitFor(tester, find.text('Note for Beef Burger'));
    await tapAndSettle(tester, find.text('Back'));
    await settle(tester);
    expect(find.text('No onions, well done'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tapAndSettle(tester, find.text('Clear All'));
    await settle(tester);
  });
}
