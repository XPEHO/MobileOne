import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

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
class FirebaseAuthMock extends Mock implements FirebaseAuth {}
void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('Tests about gallery', (WidgetTester tester) async {
final FirebaseAuth auth = FirebaseAuthMock();
      MainPage widget = MainPage();
     await tester.pumpWidget(buildTestableWidget(widget));
    await tester.pump(new Duration(milliseconds: 1000));

    //await tester.tap(find.byKey(Key("gallery_test")));
   expect(find.byKey(Key("Share")), findsOneWidget);

  });





}