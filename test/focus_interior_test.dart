import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbite/features/planet_focus/presentation/pages/planet_focus_page.dart';
import 'package:orbite/features/interior/presentation/pages/interior_page.dart';

void main() {
  testWidgets('PlanetFocusPage renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PlanetFocusPage(planetName: 'Bumi')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('InteriorPage renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: InteriorPage(planetName: 'Bumi')),
    );
    await tester.pump();
    expect(find.byType(Stack), findsWidgets);
  });
}
