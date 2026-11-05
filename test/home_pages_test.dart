import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbite/features/solar_system/presentation/pages/home_page.dart';

void main() {
  testWidgets('TriviaPage shows score', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TriviaPage()));
    await tester.pump();
    expect(find.textContaining('Skor:'), findsOneWidget);
  });

  testWidgets('SettingsPage shows toggles', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    await tester.pump();
    expect(find.byType(SwitchListTile), findsNWidgets(2));
  });
}
