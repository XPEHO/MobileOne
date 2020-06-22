import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:MobileOne/pages/create_list.dart';
import 'package:MobileOne/pages/forgotten_password.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/register-page.dart';
import 'package:MobileOne/services/analytics_service.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'localization/localization.dart';

GetIt getIt = GetIt.instance;

void instantiateServices() {
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<AnalyticsService>(AnalyticsService());
  getIt.registerSingleton<GoogleSignIn>(GoogleSignIn());
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<AuthenticationService>(AuthenticationService());
  getIt.registerSingleton<PreferencesService>(PreferencesService());
}

void main() async {
  instantiateServices();
  WidgetsFlutterBinding.ensureInitialized();
  
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
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
      initialRoute: "/",
      routes: {
        '/mainpage': (context) => MainPage(),
        '/': (context) => AuthenticationPage(),
        '/registerPage': (context) => RegisterPage(),
        '/forgottenPasswordPage': (context) => ForgottenPasswordPage(),
        '/lists': (context) => Lists(),
        '/createList': (context) => CreateList(),
      },
    );
  }
}

class HelloPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(getString(context, 'app_name')),
            RaisedButton(
              onPressed: () => openMainPage(context),
              child: Text(getString(context, 'open_main_page')),
            ),
          ],
        ),
      ),
    );
  }

  void openMainPage(context) {
    Navigator.of(context).pushNamed(
      '/mainpage',
    );
  }
}

class RssProvider extends ChangeNotifier {
  RssFeed _rssFeed = RssFeed();
  RssFeed get feed => _rssFeed;
}

Future<RssFeed> fetchRssFeed() async {
  var response = await http.get('https://itsallwidgets.com/podcast/feed');
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  return new RssFeed.parse(response.body);
}

class ProviderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureProvider(
        create: (_) => fetchRssFeed(),
        child: Consumer(
          builder: (context, RssFeed rss, _) {
            if (rss == null) {
              return Center(child: CircularProgressIndicator());
            }
            rss.items.sort((a, b) => a.title.compareTo(b.title));
            return ListView.builder(
              itemBuilder: (context, index) {
                return Text(rss.items[index].title);
              },
              itemCount: rss.items.length,
            );
          },
        ),
      ),
    );
  }
}
