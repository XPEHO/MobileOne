import 'package:MobileOne/localization/supported.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:MobileOne/main.dart';

void main() {
  group('test app widgets', () {
    setSupportedLocales([Locale('fr', 'FR')]);
    testWidgets('App display Bonjour XPEHO at start',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp());

      await tester.pump(new Duration(milliseconds: 1000));

      expect(find.text('Bonjour XPEHO'), findsOneWidget);
    });
  });
}
