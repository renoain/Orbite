import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbite/features/solar_system/presentation/widgets/scene_title_widget.dart';

void main() {
  testWidgets('Scene title renders solar system title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SceneTitleWidget())),
    );

    expect(find.text('THE SOLAR SYSTEM WITH FLUTTER'), findsOneWidget);
  });
}
