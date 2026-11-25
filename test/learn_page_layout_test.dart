import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbite/features/learn/presentation/pages/learn_page.dart';

Future<void> _waitForLoad(WidgetTester tester) async {
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
}

void main() {
  testWidgets('LearnPage matches reference sections at 360 px', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'visited_planets': <String>['Bumi'],
    });
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LearnPage()));
    await tester.pump();
    await _waitForLoad(tester);

    expect(find.text('Pelajari Planet'), findsOneWidget);
    expect(find.text('Planet Hari Ini'), findsOneWidget);
    expect(find.text('Menu Cepat'), findsOneWidget);
    expect(find.text('Daftar Planet'), findsOneWidget);
    expect(find.text('Bandingkan'), findsOneWidget);
    expect(find.text('Trivia'), findsOneWidget);
    expect(find.text('Focus'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Paspor Planet'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('Paspor Planet'), findsOneWidget);

    final bumiChip = find.widgetWithText(ActionChip, 'Bumi');
    await tester.scrollUntilVisible(
      bumiChip,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(bumiChip, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
