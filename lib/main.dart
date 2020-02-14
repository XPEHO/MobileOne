import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webfeed/webfeed.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: getSupportedLocaled(),
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
        '/secondPage': (context) => SecondPage(),
        '/provider': (context) => ProviderPage()
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
            Text(getString(context, 'hello_message')),
            RaisedButton(
              onPressed: () => openSecondPage(context),
              child: Text(getString(context, 'open_page_2')),
            ),
            RaisedButton(
              onPressed: () => openProviderPage(context),
              child: Text(getString(context, 'open_provider_page')),
            ),
          ],
        ),
      ),
    );
  }

  void openSecondPage(context) {
    Navigator.of(context).pushNamed(
      '/secondPage',
      arguments: SecondPageArguments(
        getString(context, 'hello_message'),
        getString(context, 'second_page_text'),
      ),
    );
  }

  void openProviderPage(context) {
    Navigator.of(context).pushNamed('/provider');
  }
}

class SecondPageArguments {
  final String title;
  final String text;

  SecondPageArguments(this.title, this.text);
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SecondPageArguments arguments =
        ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text(arguments.title),
      ),
      body: Center(
        child: Text(arguments.text),
      ),
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
