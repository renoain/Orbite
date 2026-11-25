import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orbite/features/trivia/presentation/pages/trivia_page.dart';

Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  testWidgets('TriviaPage runs a full round and restarts', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TriviaPage()));
    await tester.pumpAndSettle();

    expect(find.text('Pertanyaan 1 dari 6'), findsOneWidget);
    expect(find.text('Skor: 0/6'), findsOneWidget);

    await _tapText(tester, 'Jupiter');
    expect(find.text('Benar!'), findsOneWidget);
    expect(find.textContaining('diameter sekitar 143.000 km'), findsOneWidget);

    const answers = ['Mars', 'Saturnus', 'Merkurius', 'Neptunus', 'Uranus'];
    await _tapText(tester, 'Lanjut');

    for (var i = 0; i < answers.length; i++) {
      expect(find.text('Pertanyaan ${i + 2} dari 6'), findsOneWidget);
      await _tapText(tester, answers[i]);
      expect(find.text('Benar!'), findsOneWidget);
      await _tapText(tester, i == answers.length - 1 ? 'Lihat Skor' : 'Lanjut');
    }

    expect(find.text('Trivia selesai'), findsOneWidget);
    expect(find.text('6 / 6'), findsOneWidget);
    expect(find.text('100% benar'), findsOneWidget);

    await _tapText(tester, 'Main Lagi');
    expect(find.text('Pertanyaan 1 dari 6'), findsOneWidget);
    expect(find.text('Skor: 0/6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
