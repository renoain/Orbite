import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/features/solar_system/presentation/pages/planet_list_page.dart';

import 'support/fake_planets.dart';

void main() {
  testWidgets('PlanetListPage renders grid', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      MaterialApp(home: PlanetListPage(loadPlanets: () async => fakePlanets())),
    );
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();
    expect(find.byType(GridView), findsOneWidget);
  });
}
