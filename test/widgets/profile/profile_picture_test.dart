import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import '../../authentication_test.dart';


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
class ImageServiceMock extends Mock implements ImageService {}
class UserServiceMock extends Mock implements UserService {}
class PreferencesMock extends Mock implements PreferencesService {}
void main() {
  setSupportedLocales([Locale("fr", "FR")]);
  testWidgets("Open camera and see profile picture changed",
      (WidgetTester tester) async {

    // GIVEN
    final auth = FirebaseAuthMock();
    final user = FirebaseUserMock();
    final _googleSignIn = MockGoogleSignIn();
    final _userService = UserServiceMock();
        final _imageService = ImageServiceMock();
       final _preferenceService = PreferencesServiceMock();  

    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);
    GetIt.instance.registerSingleton<FirebaseAuth>(auth);
    GetIt.instance.registerSingleton<FirebaseUser>(user);
    GetIt.I.registerSingleton<AuthenticationService>(AuthenticationService());
    GetIt.I.registerSingleton<UserService>(_userService);
    GetIt.I.registerSingleton<ImageService>(_imageService);
    GetIt.I.registerSingleton<PreferencesServiceMock>(_preferenceService);

    when(_imageService.pickCamera()).thenAnswer((realInvocation) =>
        Future.value(PickedFile("assets/images/facebook_f.png")));
    when(_userService.user).thenReturn(user);

    
    // WHEN
    await tester.pumpWidget(buildTestableWidget(MainPage()));
    /*await tester.pump(new Duration(milliseconds: 1000));

    await tester.tap(find.byKey(Key(KEY_PROFILE_PAGE)));
    await tester.pump(new Duration(milliseconds: 1000));

    await tester.tap(find.byKey(Key("floating_button")));*/



    // THEN
   // verify(_prefService.setString(any, "assets/images/facebook_f.png"));
  });
  /*testWidgets("Open gallery and see profile picture changed",
      (WidgetTester tester) async {

    final auth = FirebaseAuthMock();
    GetIt.instance.registerSingleton<FirebaseAuth>(auth);
    final user = UserServiceMock();
    GetIt.I.registerSingleton<UserService>(user);
    final _imageService = ImageServiceMock();
    GetIt.I.registerSingleton<ImageService>(_imageService);
    final _prefService = PreferencesMock();
    GetIt.I.registerSingleton<PreferencesService>(_prefService);

    when(_imageService.pickGallery()).thenAnswer((realInvocation) =>
        Future.value(PickedFile("assets/images/facebook_f.png")));
    // WHEN
   await tester.pumpWidget(buildTestableWidget(Profile()));
    await tester.pump(new Duration(seconds: 3));

    await tester.tap(find.byKey(Key("take_picture_from_gallery")));
    // THEN
   // verify(_prefService.setString(any, "assets/images/facebook_f.png"));
  });*/
}