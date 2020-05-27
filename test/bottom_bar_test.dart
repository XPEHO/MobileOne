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

class FirebaseUserMock extends Mock implements FirebaseUser {}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('Go the the specifical page', (WidgetTester tester) async {
    MainPage _widget = new MainPage();

    await tester.pumpWidget(buildTestableWidget(_widget));
    await tester.pump(new Duration(milliseconds: 1000));

    await tester.tap(find.byKey(Key("Cards")));
    expect(find.text('Cartes'), findsOneWidget);

    await tester.tap(find.byKey(Key("Lists")));
    expect(find.text('Listes'), findsNWidgets(2));

    await tester.tap(find.byKey(Key("Share")));
    expect(find.text('Partager'), findsOneWidget);

    await tester.tap(find.byKey(Key("Profile")));
    expect(find.text('Profil'), findsOneWidget);
  });
}
