import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('Go the the specifical page', (WidgetTester tester) async {
    /*Widget widget;
    BottomBarItem _item;
    void goToPage(int index) {}
    Color color = Colors.black;
    String key = "";
    String nom = "";
    var icon;

    var t = BottomBarItem(KEY_LISTS_PAGE, Colors.white, goToPage, 'Listes', Icons.list);

    onListSelected(int index) {
      key = KEY_LISTS_PAGE;
      color = Colors.white;
      nom = 'Listes';
      icon = Icons.list;
      _item = BottomBarItem(key, color, goToPage, nom, icon);
    }

    onCardSelected(int index) {
      key = KEY_CARD_PAGE;
      color = Colors.white;
      nom = 'Cartes';
      icon = Icons.card_giftcard;
      _item = BottomBarItem(key, color, goToPage, nom, icon);
    }

    onShareSelected(int index) {
      key = KEY_SHARE_PAGE;
      color = Colors.white;
      nom = 'Partager';
      icon = Icons.share;
      _item = BottomBarItem(key, color, goToPage, nom, icon);
    }

    onProfileSelected(int index) {
      key = KEY_PROFILE_PAGE;
      color = Colors.orange;
      nom = 'Profile';
      icon = Icons.person;
      _item = BottomBarItem(key, color, goToPage, nom, icon);
    }

    widget = buildTestableWidget(BottomBar(onListSelected));
    await tester.pumpWidget(widget);
    await tester.pump(new Duration(milliseconds: 1000));
   //expect(color, Colors.black);
    await tester.tap(find.text('Listes'));
    expect(_item.createElement(), Key(KEY_LISTS_PAGE));


    /*color = Colors.black;
    widget = buildTestableWidget(BottomBar(onCardSelected));
    await tester.pumpWidget(widget);
    await tester.pump(new Duration(milliseconds: 1000));
    expect(color, Colors.black);
    await tester.tap(find.text('Cartes'));
    expect(color, Colors.white);

    color = Colors.black;
    widget = buildTestableWidget(BottomBar(onShareSelected));
    await tester.pumpWidget(widget);
    await tester.pump(new Duration(milliseconds: 1000));
    expect(color, Colors.black);
    await tester.tap(find.text('Partager'));
    expect(color, Colors.white);*/

    /* color = Colors.black;
    widget = buildTestableWidget(BottomBar(onProfileSelected));
    await tester.pumpWidget(widget);
    await tester.pump(new Duration(milliseconds: 1000));
    expect(color, Colors.black);
    await tester.tap(find.text('Profile'));
   expect(color, Colors.orange);
*/
  */
  });
}
