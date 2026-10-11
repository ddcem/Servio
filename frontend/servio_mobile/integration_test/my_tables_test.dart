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

  /// Needs table 2 assigned to the demo waiter and table 3 to a colleague.
  testWidgets('my tables', (tester) async {
    SharedPreferences.setMockInitialValues({'waiter_guide_seen': true, 'language': 'en'});
    app.main();
    await waitFor(tester, find.text('Waiter Login'));
    await tester.enterText(find.byType(TextFormField).at(0), 'mobile');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await tapAndSettle(tester, find.text('Login'));

    await waitFor(tester, find.text('My tables'));
    await shot(tester, 't01_my_tables');
    expect(find.text('3'), findsNothing);

    await tapAndSettle(tester, find.text('All tables'));
    await waitFor(tester, find.text('3'));
    await shot(tester, 't02_all_tables');
    await tapAndSettle(tester, find.text('3'));
    await waitFor(tester, find.textContaining('is served by Mike Williams'));
    await shot(tester, 't03_locked');
  });
}
