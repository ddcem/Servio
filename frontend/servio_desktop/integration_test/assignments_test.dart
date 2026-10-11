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

  /// Builds a shift plan on the assignment board: one real drag, one move through the card menu and
  /// one whole area through the column menu.
  testWidgets('table assignment board', (tester) async {
    app.main();
    await waitFor(tester, find.byType(LanguageMenuButton));
    await tester.tap(find.byType(LanguageMenuButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await waitFor(tester, find.text('Staff Login'));
    await login(tester, 'desktop');
    await waitFor(tester, find.text('Admin Dashboard'));
    await tester.tap(find.text('Admin Panel'));
    await waitFor(tester, find.text('Menu Management'));
    await openSection(tester, 'Tables');
    await waitFor(tester, find.text('Assign waiters'));
    await tester.tap(find.text('Assign waiters'));
    await waitFor(tester, find.text('Table Assignments'));
    await waitFor(tester, find.text('John Smith'));
    await shot(tester, 'a01_board_empty');

    // Drag table 2 from "Unassigned" onto John's column.
    final card = find.text('Table 2');
    final johnColumn = find.ancestor(of: find.text('John Smith'), matching: find.byType(DragTarget<RestaurantTable>));
    final gesture = await tester.startGesture(tester.getCenter(card));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(card) + const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(johnColumn));
    await tester.pump(const Duration(milliseconds: 300));
    await shot(tester, 'a02_dragging');
    await gesture.up();
    await waitFor(tester, find.text('Table 2 → John Smith'));

    // Table 3 to Mike through the card menu.
    final table3 = find.ancestor(of: find.text('Table 3'), matching: find.byType(Stack)).first;
    await tester.tap(find.descendant(of: table3, matching: find.byTooltip('Move to…')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mike Williams').last);
    await waitFor(tester, find.text('Table 3 → Mike Williams'));

    // The whole terrace to Lejla through her column menu.
    final lejla = find.ancestor(of: find.text('Lejla Begić'), matching: find.byType(DragTarget<RestaurantTable>));
    await tester.tap(find.descendant(of: lejla, matching: find.byTooltip('Column actions')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add all of Terrace'));
    await waitFor(tester, find.textContaining('→ Lejla Begić'));
    await tester.pump(const Duration(seconds: 1));
    await shot(tester, 'a03_board_assigned');

    await tester.tap(find.byTooltip('Back'));
    await waitFor(tester, find.text('WAITER'));
    await shot(tester, 'a04_tables_list');
  });
}
