import 'dart:async';
import 'package:MobileOne/dao/loyalty_cards_dao.dart';
import 'package:MobileOne/dao/picture_dao.dart';
import 'package:MobileOne/dao/recipes_dao.dart';
import 'package:MobileOne/dao/user_dao.dart';
import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/pages/big_loyaltycard.dart';
import 'package:MobileOne/pages/items_page.dart';
import 'package:MobileOne/pages/loyaltycards_page.dart';
import 'package:MobileOne/pages/opened_recipe_page.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/recipes_page.dart';
import 'package:MobileOne/pages/settings_page.dart';
import 'package:MobileOne/pages/splash.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/providers/package_info_provider.dart';
import 'package:MobileOne/providers/recipeItems_provider.dart';
import 'package:MobileOne/providers/recipes_provider.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:MobileOne/pages/share_one.dart';
import 'package:MobileOne/pages/share_two.dart';
import 'package:MobileOne/rest/email_rest_client.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/email_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/picture_service.dart';
import 'package:MobileOne/services/recipes_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:MobileOne/services/loyalty_cards_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
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

import 'dao/messaging_dao.dart';

GetIt getIt = GetIt.instance;

void instantiateServices() {
  getIt.registerSingleton(FirebaseAuth.instance);
  getIt.registerSingleton(AnalyticsService());
  getIt.registerSingleton(PreferencesService());
  getIt.registerSingleton(UserDao());
  getIt.registerSingleton(UserService());
  getIt.registerSingleton(MessagingDao());
  getIt.registerSingleton(MessagingService());
  getIt.registerSingleton(PictureDao());
  getIt.registerSingleton(PictureService());
  getIt.registerSingleton(EmailRestClient());
  getIt.registerSingleton(EmailService());

  getIt.registerSingleton(RecipesDao());
  getIt.registerSingleton(RecipesService());
  getIt.registerSingleton(RecipesProvider());
  getIt.registerSingleton(RecipeItemsProvider());

  getIt.registerSingleton(LoyaltyCardsDao());
  getIt.registerSingleton(LoyaltyCardsService());

  getIt.registerSingleton(GoogleSignIn());
  getIt.registerSingleton(WishlistDao());

  getIt.registerSingleton(WishlistService());
  getIt.registerSingleton(AuthenticationService());
  getIt.registerSingleton(ColorService());
  getIt.registerSingleton(ImageService());
  getIt.registerSingleton(WishlistsListProvider());
  getIt.registerSingleton(ItemsListProvider());
  getIt.registerSingleton(ShareProvider());
  getIt.registerSingleton(LoyaltyCardsProvider());
  getIt.registerSingleton(UserPictureProvider());
  getIt.registerSingleton(WishlistHeadProvider());
  getIt.registerSingleton(PackageInfoProvider());

  getIt.registerSingleton(ShareService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  instantiateServices();

  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatefulWidget {
  MyApp({this.app});
  final FirebaseApp app;

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final _preferencesService = GetIt.I.get<PreferencesService>();
  final _messagingService = GetIt.I.get<MessagingService>();

  @override
  void initState() {
    super.initState();
    _messagingService.configureMessaging();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _preferencesService.initSharedPreferences();
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
      supportedLocales: getSupportedLocales(),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate
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
        '/openedListPage': (context) => OpenedListPage(),
        '/shareOne': (context) => ShareOne(),
        '/shareTwo': (context) => ShareTwo(),
        '/share': (context) => Share(),
        "/cards": (contaxt) => Cards(),
        "/loyaltycards": (contaxt) => LoyaltyCards(),
        "/profile": (context) => Profile(),
        "/createItem": (context) => EditItemPage(),
        "/settings": (context) => SettingsPage(),
        "/recipes": (context) => RecipesPage(),
        "/openedRecipePage": (context) => OpenedRecipePage(),
      },
    );
  }
}
