import 'dart:async';
import 'package:MobileOne/pages/card_page.dart';
import 'package:MobileOne/pages/items_page.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/splash.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:MobileOne/pages/share_one.dart';
import 'package:MobileOne/pages/share_two.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:MobileOne/pages/create_list.dart';
import 'package:MobileOne/pages/forgotten_password.dart';
import 'package:MobileOne/pages/openedListPage.dart';
import 'package:MobileOne/pages/register-page.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

GetIt getIt = GetIt.instance;

void instantiateServices() {
  getIt.registerSingleton(UserService());
  getIt.registerSingleton(AnalyticsService());
  getIt.registerSingleton(GoogleSignIn());
  getIt.registerSingleton(FirebaseAuth.instance);
  getIt.registerSingleton(AuthenticationService());
  getIt.registerSingleton(PreferencesService());
  getIt.registerSingleton(WishlistsListProvider());
  getIt.registerSingleton(ItemsListProvider());
  getIt.registerSingleton(ShareProvider());
  getIt.registerSingleton(LoyaltyCardsProvider());
  getIt.registerSingleton(ImageService());
  getIt.registerSingleton(UserPictureProvider());
  getIt.registerSingleton(WishlistHeadProvider());
  getIt.registerSingleton(ColorService());
  getIt.registerSingleton(ShareService());
}

void main() {
  instantiateServices();
  WidgetsFlutterBinding.ensureInitialized();

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  MyApp({this.app});
  final FirebaseApp app;

  final _preferencesService = GetIt.I.get<PreferencesService>();

  @override
  Widget build(BuildContext context) {
    _preferencesService.initSharedPreferences();
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
      initialRoute: "/splash",
      routes: {
        '/splash': (context) => SplashPage(),
        '/mainPage': (context) => MainPage(),
        '/authentication': (context) => AuthenticationPage(),
        '/registerPage': (context) => RegisterPage(),
        '/forgottenPasswordPage': (context) => ForgottenPasswordPage(),
        '/createList': (context) => CreateList(),
        '/openedListPage': (context) => OpenedListPage(),
        '/shareOne': (context) => ShareOne(),
        '/shareTwo': (context) => ShareTwo(),
        '/share': (context) => Share(),
        "/cards": (contaxt) => Cards(),
        "/loyaltycards": (contaxt) => LoyaltyCards(),
        "/profile": (context) => Profile(),
        "/createItem": (context) => EditItemPage(),
      },
    );
  }
}
