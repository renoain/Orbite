import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbite/core/widgets/three_scene_canvas.dart';
import 'package:orbite/features/eclipse/presentation/pages/eclipse_page.dart';
import 'package:orbite/features/seasons/presentation/pages/seasons_page.dart';

void main() {
  testWidgets('SeasonsPage renders the 3D canvas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SeasonsPage()));
    await tester.pump();

    expect(find.byType(ThreeSceneCanvas), findsOneWidget);
    expect(find.text('Musim & Kemiringan Bumi'), findsOneWidget);
  });

  testWidgets('EclipsePage renders the 3D canvas', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: EclipsePage()));
    await tester.pump();

    expect(find.byType(ThreeSceneCanvas), findsOneWidget);
    expect(find.text('Gerhana 3D'), findsOneWidget);
  });
}
