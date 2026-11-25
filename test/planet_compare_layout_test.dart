import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbite/features/solar_system/presentation/pages/planet_compare_page.dart';

Future<void> _waitForLoad(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
}

void main() {
  testWidgets('PlanetComparePage holds a 320 px width', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: PlanetComparePage()));
    await tester.pump();
    await _waitForLoad(tester);

    expect(find.text('Planet A'), findsOneWidget);
    expect(find.text('Planet B'), findsOneWidget);
    expect(find.text('Tukar A dan B'), findsOneWidget);
    expect(find.text('Diameter'), findsOneWidget);
    expect(find.text('Merkurius'), findsWidgets);
    expect(find.text('Venus'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Gravitasi'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Gravitasi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
