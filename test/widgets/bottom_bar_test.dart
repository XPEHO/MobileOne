import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
//import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestableWidget(Widget widget) {
  return MaterialApp(
      supportedLocales: getSupportedLocales(),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback:
          (Locale locale, Iterable<Locale> supportedLocales) {
        for (Locale supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode ||
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }

        return supportedLocales.first;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: widget);
}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);
  //var onItemSelected;

  testWidgets('Bottom bar tests', (WidgetTester tester) async {
    /*//Test function call on item selected

    //GIVEN
    bool functionCalled = false;
    int indexSelected = -1;
    onItemSelected = (index) {
      functionCalled = true;
      indexSelected = index;
    };

    //WHEN
    await tester.pumpWidget(buildTestableWidget(new BottomBar(onItemSelected)));
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.byKey(Key(KEY_CARD_PAGE)));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //THEN
    expect(functionCalled, true);
    expect(indexSelected, CARD_PAGE);

    //Test lists button

    //GIVEN

    onItemSelected = (index) {};

    //WHEN
    await tester.pumpWidget(buildTestableWidget(new BottomBar(onItemSelected)));
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.byKey(Key(KEY_LISTS_PAGE)));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //THEN
    expect(find.byKey(Key(KEY_LISTS_PAGE + "_selected")), findsOneWidget);
    expect(find.byKey(Key(KEY_CENTER_TEXT)), findsOneWidget);
    expect(find.text("Nouvelle liste"), findsOneWidget);

    //Test Profile button

    //GIVEN

    onItemSelected = (index) {};

    //WHEN
    await tester.pumpWidget(buildTestableWidget(new BottomBar(onItemSelected)));
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.byKey(Key(KEY_PROFILE_PAGE)));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //THEN
    expect(find.byKey(Key(KEY_PROFILE_PAGE + "_selected")), findsOneWidget);
    expect(find.byKey(Key(KEY_CENTER_TEXT)), findsOneWidget);
    expect(find.text("Photo"), findsOneWidget);

    //Test card button

    //GIVEN

    onItemSelected = (index) {};

    //WHEN
    await tester.pumpWidget(buildTestableWidget(new BottomBar(onItemSelected)));
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.byKey(Key(KEY_CARD_PAGE)));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //THEN
    expect(find.byKey(Key(KEY_CARD_PAGE + "_selected")), findsOneWidget);
    expect(find.byKey(Key(KEY_CENTER_TEXT)), findsOneWidget);
    expect(find.text("Nouvelle carte"), findsOneWidget);

    //Test share button
    //GIVEN

    onItemSelected = (index) {};

    //WHEN
    await tester.pumpWidget(buildTestableWidget(new BottomBar(onItemSelected)));
    await tester.pumpAndSettle(Duration(seconds: 2));
    await tester.tap(find.byKey(Key(KEY_SHARE_PAGE)));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //THEN
    expect(find.byKey(Key(KEY_SHARE_PAGE + "_selected")), findsOneWidget);
    expect(find.byKey(Key(KEY_CENTER_TEXT)), findsOneWidget);
    expect(find.text("Partages"), findsOneWidget);*/
  });
}
