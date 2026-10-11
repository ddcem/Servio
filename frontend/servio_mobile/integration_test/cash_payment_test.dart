import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:printing/printing.dart';
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

  /// Needs an open order of the demo waiter on table 10 whose kitchen and bar tickets are ready.
  testWidgets('cash payment with receipt', (tester) async {
    SharedPreferences.setMockInitialValues({'waiter_guide_seen': true});
    app.main();

    await waitFor(tester, find.text('Waiter Login'));
    await tester.enterText(find.byType(TextFormField).at(0), 'mobile');
    await tester.enterText(find.byType(TextFormField).at(1), 'test');
    await tapAndSettle(tester, find.text('Login'));
    await waitFor(tester, find.text('OCC'));

    final grid = find.byType(CustomScrollView);
    final card = find.descendant(of: grid, matching: find.text('10'));
    await tester.scrollUntilVisible(
      card,
      300,
      scrollable: find.descendant(of: grid, matching: find.byType(Scrollable)).first,
    );
    await tapAndSettle(tester, card.first);
    await waitFor(tester, find.text('Mark served'));
    await shot(tester, 'p01_ready_to_serve');
    while (find.text('Mark served').evaluate().isNotEmpty) {
      await tapAndSettle(tester, find.text('Mark served').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }
    await shot(tester, 'p02_served');

    await tapAndSettle(tester, find.text('Payment'));
    await waitFor(tester, find.text('Process Payment'));
    await tapAndSettle(tester, find.text('10%'));
    await tapAndSettle(tester, find.text('Cash'));
    await tapAndSettle(tester, find.text('Exact'));
    await shot(tester, 'p03_cash_exact');
    await tapAndSettle(tester, find.text('Complete Cash Payment'));
    await waitFor(tester, find.text('Take payment?'));
    await shot(tester, 'p04_confirm');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Confirm'));
    await waitFor(tester, find.text('Table 10 paid'));
    await shot(tester, 'p05_paid');
    await tapAndSettle(tester, find.text('Receipt'));
    await waitFor(tester, find.byType(PdfPreview), seconds: 30);
    await tester.pump(const Duration(seconds: 3));
    await shot(tester, 'p06_receipt');

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapAndSettle(tester, find.byTooltip('More'));
    await tapAndSettle(tester, find.text('Order history'));
    await waitFor(tester, find.textContaining('Table 10'));
    await shot(tester, 'p07_history');
    await tapAndSettle(tester, find.textContaining('Table 10').first);
    await waitFor(tester, find.text('View receipt'));
    await shot(tester, 'p08_order_details');
  });
}
