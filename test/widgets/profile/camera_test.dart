import 'package:MobileOne/dao/messaging_dao.dart';
import 'package:MobileOne/dao/recipes_dao.dart';
import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
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

class FirebaseUserMock extends Mock implements User {}

class UserServiceMock extends Mock implements UserService {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class ImageServiceMock extends Mock implements ImageService {}

class PreferencesMock extends Mock implements PreferencesService {}

class AuthServiceMock extends Mock implements AuthenticationService {}

class PickerMock extends Mock implements ImagePicker {}

class WishlistListProviderMock extends Mock implements WishlistsListProvider {}

class UserPictureProviderMock extends Mock implements UserPictureProvider {}

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class ColorServiceMock extends Mock implements ColorService {}

class ShareServiceMock extends Mock implements ShareService {}

class LoyaltyCardsProviderMock extends Mock implements LoyaltyCardsProvider {}

class LoyaltyCardsServiceMock extends Mock implements LoyaltyCardsService {}

void main() {
  setSupportedLocales([Locale("fr", "FR")]);
  testWidgets("Open camera and see profile picture changed",
      (WidgetTester tester) async {
    // GIVEN
    final user = FirebaseUserMock();
    GetIt.instance.registerSingleton<User>(user);

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
    final _authService = AuthServiceMock();
    GetIt.I.registerSingleton<AuthenticationService>(_authService);
    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);
    final _colorService = ColorServiceMock();
    GetIt.I.registerSingleton<ColorService>(_colorService);
    final _shareService = ShareServiceMock();
    GetIt.I.registerSingleton<ShareService>(_shareService);
    final _loyaltycardsService = LoyaltyCardsServiceMock();
    GetIt.I.registerSingleton<LoyaltyCardsService>(_loyaltycardsService);
    final _loyaltycardsProvider = LoyaltyCardsProviderMock();
    GetIt.I.registerSingleton<LoyaltyCardsProvider>(_loyaltycardsProvider);
    GetIt.I.registerSingleton<RecipesDao>(RecipesDao());
    GetIt.I.registerSingleton<RecipesService>(RecipesService());
    GetIt.I.registerSingleton<MessagingDao>(MessagingDao());
    GetIt.I.registerSingleton<MessagingService>(MessagingService());
    GetIt.I.registerSingleton<WishlistDao>(WishlistDao());
    GetIt.I.registerSingleton<WishlistService>(WishlistService());

    when(_picker.getImage(source: ImageSource.camera)).thenAnswer(
        (_) => Future.value(PickedFile("assets/images/facebook_f.png")));
    when(_imageService.pickCamera(100, 1080, 1080)).thenAnswer(
        (_) => Future.value(PickedFile("assets/images/facebook_f.png")));
    when(_userService.user).thenReturn(user);
    when(user.displayName).thenReturn("");
    when(user.email).thenReturn("test@test.test");
    when(user.uid).thenReturn("42");
    when(_wishlistProvider.ownerLists).thenReturn(List());
    when(_wishlistProvider.guestLists(any)).thenReturn(List());
    when(auth.currentUser).thenReturn(user);
    when(user.providerData).thenReturn([]);

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
