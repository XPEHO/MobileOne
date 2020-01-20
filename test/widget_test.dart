import 'package:flutter_test/flutter_test.dart';

import 'package:MobileOne/main.dart';

void main() {
  testWidgets('App display Hello XPEHO at start', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    expect(find.text('Hello XPEHO'), findsOneWidget);
  });
}
