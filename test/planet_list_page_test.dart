import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbite/features/solar_system/presentation/pages/planet_list_page.dart';

void main() {
  testWidgets('PlanetListPage renders grid', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PlanetListPage()));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });
}
