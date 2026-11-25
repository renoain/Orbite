import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/features/home/presentation/pages/cosmic_explore.dart';

Future<void> _waitForLoad(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
}

void main() {
  testWidgets('CosmicExplore holds a 360 px width', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: CosmicExplore()));
    await tester.pump();
    await _waitForLoad(tester);

    expect(find.text('Orbite'), findsOneWidget);
    expect(find.text('Jelajah 3D'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Paspor Planet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Paspor Planet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
