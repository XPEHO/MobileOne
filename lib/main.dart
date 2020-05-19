import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:MobileOne/pages/Mainpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'authentication_service.dart';

import 'localization/localization.dart';

FirebaseUser _user;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      initialRoute: '/',
      routes: {
        '/': (context) => HelloPage(),
        '/mainpage': (context) => MainPage(),
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
            RaisedButton.icon(
              onPressed: () async { 
                              AuthenticationService().googleSignIn()
                              .then((FirebaseUser user) {
                                _user = user;
                                openMainPage(context);
                                Fluttertoast.showToast(msg: getString(context, 'google_signin'));
                              })
                              .catchError((e) => Fluttertoast.showToast(msg: e)); 
                            },
              label: Text(getString(context, 'google'), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),), 
              color: Colors.white,
              icon: new Image.asset('lib/assets/images/Google_g.png', width: 20,),              
            ),
            RaisedButton(
              onPressed: () async {
                if (_user == null) {
                  Fluttertoast.showToast(msg: getString(context, 'no_user'));
                } else {
                  AuthenticationService().signOut();
                  _user = null;
                  Fluttertoast.showToast(msg: getString(context, 'signed_out'));
                }
              },
              child: Text(getString(context, 'signout')),
            )
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
