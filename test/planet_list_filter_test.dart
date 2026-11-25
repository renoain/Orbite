import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/features/solar_system/presentation/pages/planet_list_page.dart';

Future<void> _waitForLoad(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
}

void main() {
  testWidgets('PlanetListPage filters planets and clears search', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: PlanetListPage()));
    await tester.pump();
    await _waitForLoad(tester);

    expect(find.text('Merkurius'), findsOneWidget);
    expect(find.text('Matahari'), findsNothing);
    expect(find.text('8 planet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'mars');
    await tester.pump();
    expect(find.text('1 planet'), findsOneWidget);
    expect(find.text('Mars'), findsOneWidget);
    expect(find.text('Merkurius'), findsNothing);

    await tester.enterText(find.byType(TextField), 'tidak-ada');
    await tester.pump();
    expect(find.textContaining('Tidak ada planet untuk'), findsOneWidget);

    await tester.tap(find.text('Hapus pencarian'));
    await tester.pump();
    expect(find.text('8 planet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
