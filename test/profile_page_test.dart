import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);
  testWidgets('Tests Profile Page', (WidgetTester tester) async {
    final auth = FirebaseAuthMock();
    final user = FirebaseUserMock();
    final _googleSignIn = MockGoogleSignIn();

    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);
    GetIt.instance.registerSingleton<FirebaseAuth>(auth);
    GetIt.instance.registerSingleton<FirebaseUser>(user);
    GetIt.I.registerSingleton<AuthenticationService>(AuthenticationService());

    when(auth.currentUser()).thenAnswer((realInvocation) => Future.value(user));

    when(user.displayName).thenReturn("Dupond Jean");
    expect(user.displayName, "Dupond Jean");

    when(user.email).thenReturn("Dupond.Jean@gmail.com");
    expect(user.email, "Dupond.Jean@gmail.com");

    when(user.photoUrl).thenReturn("");

    Profile widget = Profile();
    var testableWidget = buildTestableWidget(widget);
    await tester.pumpWidget(testableWidget);
    await tester.pumpAndSettle(Duration(seconds: 3));
    await tester.tap(find.byKey(Key("Password")));

    expect(find.text('Changer mon mot de passe'), findsOneWidget);
  });
}
