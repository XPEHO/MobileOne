import 'package:MobileOne/dao/messaging_dao.dart';
import 'package:MobileOne/dao/recipes_dao.dart';
import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/loyalty_cards_service.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/recipes_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
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

class FirebaseUserMock extends Mock implements User {}

class UserServiceMock extends Mock implements UserService {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class PreferencesMock extends Mock implements PreferencesService {}

class ImageServiceMock extends Mock implements ImageService {}

class UserPictureMock extends Mock implements UserPictureProvider {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class ColorServiceMock extends Mock implements ColorService {}

class ShareServiceMock extends Mock implements ShareService {}

class LoyaltyCardsServiceMock extends Mock implements LoyaltyCardsService {}

class LoyaltyCardsProvidermock extends Mock implements LoyaltyCardsProvider {}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('Profile Page should display allow password modification',
      (WidgetTester tester) async {
    //GIVEN
    Widget widget = buildTestableWidget(Profile());

    final auth = FirebaseAuthMock();
    final user = FirebaseUserMock();
    final _googleSignIn = MockGoogleSignIn();
    final _imageService = ImageServiceMock();
    final _userService = UserServiceMock();
    final _prefs = PreferencesMock();
    final _picture = UserPictureMock();
    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);
    GetIt.I.registerSingleton<UserService>(_userService);
    GetIt.I.registerSingleton<GoogleSignIn>(_googleSignIn);
    GetIt.instance.registerSingleton<FirebaseAuth>(auth);
    GetIt.instance.registerSingleton<User>(user);
    GetIt.I.registerSingleton<AuthenticationService>(AuthenticationService());
    GetIt.I.registerSingleton<ImageService>(_imageService);
    GetIt.I.registerSingleton<PreferencesService>(_prefs);
    GetIt.I.registerSingleton<UserPictureProvider>(_picture);
    final _colorService = ColorServiceMock();
    GetIt.I.registerSingleton<ColorService>(_colorService);
    final _shareService = ShareServiceMock();
    GetIt.I.registerSingleton<ShareService>(_shareService);
    final _loyaltycardsService = LoyaltyCardsServiceMock();
    GetIt.I.registerSingleton<LoyaltyCardsService>(_loyaltycardsService);
    final _loyaltycardsProvider = LoyaltyCardsProvider();
    GetIt.I.registerSingleton<LoyaltyCardsProvider>(_loyaltycardsProvider);
    GetIt.I.registerSingleton<RecipesDao>(RecipesDao());
    GetIt.I.registerSingleton<RecipesService>(RecipesService());
    GetIt.I.registerSingleton<MessagingDao>(MessagingDao());
    GetIt.I.registerSingleton<MessagingService>(MessagingService());
    GetIt.I.registerSingleton<WishlistDao>(WishlistDao());
    GetIt.I.registerSingleton<WishlistService>(WishlistService());

    when(auth.currentUser).thenReturn(user);
    final _displayName = "Dupond Jean";
    when(user.displayName).thenReturn(_displayName);

    final _email = "Dupond.Jean@gmail.com";
    when(user.email).thenReturn(_email);

    when(user.photoURL).thenReturn("");

    when(user.providerData).thenReturn(List.of([]));

    when(_userService.user).thenReturn(user);

    //WHEN
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle(Duration(seconds: 3));
    await tester.tap(find.byKey(Key(KEY_PASSWORD)));

    //THEN
    expect(find.text('Changer mon mot de passe'), findsOneWidget);
  });
}
