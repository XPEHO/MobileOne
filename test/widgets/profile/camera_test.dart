import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
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

class UserServiceMock extends Mock implements UserService {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class ImageServiceMock extends Mock implements ImageService {}

class PreferencesMock extends Mock implements PreferencesService {}

class PickerMock extends Mock implements ImagePicker {}

class WishlistListProviderMock extends Mock implements WishlistsListProvider {}

class UserPictureProviderMock extends Mock implements UserPictureProvider {}

void main() {
  setSupportedLocales([Locale("fr", "FR")]);
  testWidgets("Open camera and see profile picture changed",
      (WidgetTester tester) async {
    // GIVEN
    final user = FirebaseUserMock();
    GetIt.instance.registerSingleton<FirebaseUser>(user);

    final _userService = UserServiceMock();
    GetIt.I.registerSingleton<UserService>(_userService);
    final _googleSignIn = MockGoogleSignIn();
    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);
    final auth = FirebaseAuthMock();
    GetIt.I.registerSingleton<FirebaseAuth>(auth);
    final _prefService = PreferencesMock();
    GetIt.I.registerSingleton<PreferencesService>(_prefService);
    final _picker = PickerMock();
    GetIt.I.registerSingleton<ImagePicker>(_picker);
    final _imageService = ImageServiceMock();
    GetIt.I.registerSingleton<ImageService>(_imageService);
    final _wishlistProvider = WishlistListProviderMock();
    GetIt.I.registerSingleton<WishlistsListProvider>(_wishlistProvider);
    final _userPicture = UserPictureProviderMock();
    GetIt.I.registerSingleton<UserPictureProvider>(_userPicture);
    when(_userService.user).thenReturn(user);

    when(_picker.getImage(source: ImageSource.camera)).thenAnswer(
        (_) => Future.value(PickedFile("assets/images/facebook_f.png")));

    when(_imageService.pickCamera()).thenAnswer(
        (_) => Future.value(PickedFile("assets/images/facebook_f.png")));
    when(_userService.user).thenReturn(user);
    when(user.email).thenReturn("test@test.test");
    when(user.uid).thenReturn("42");
    // WHEN
    await tester.pumpWidget(buildTestableWidget(MainPage()));
    await tester.pump(new Duration(milliseconds: 1000));
    await tester.tap(find.byKey(Key(KEY_PROFILE_PAGE)));
    await tester.pump(new Duration(milliseconds: 1000));
    await tester.tap(find.byKey(Key("floating_button")));
    await tester.pump(new Duration(milliseconds: 1000));
    // THEN
    verify(_prefService.setString("picture42", "assets/images/facebook_f.png"));
  });
}
