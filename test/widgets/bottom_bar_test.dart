import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('Go the the specifical page', (WidgetTester tester) async {
    var _currentItem;
    BottomBarItem currentScreen;
    var key_used;
    var _current;
    var isSelected=false;
    goToPage(int index) {
      if (index == 0) {
        _current = LoyaltyCards();
      }
      if (index == 1) {
        _current = Lists();
        isSelected=true;
      }
      if (index == 2) {
        _current = LoyaltyCards();
      }
      if (index == 3) {
        _current = Lists();
      }
    }
    isSelect(index){
       if (index == 0) {
        _current = LoyaltyCards();
      }
      if (index == 1) {
      
        
      }
      if (index == 2) {
        _current = LoyaltyCards();
      }
      if (index == 3) {
        _current = Lists();
      }
    }
 Color color=Colors.black;
var test;
    onItemSelected(int index) {
      if (index == 0) {
       
        test= "Cards";
      }
      if (index == 1) {
      currentScreen = BottomBarItem("key_used",color,goToPage,'Listes',Icons.list,isSelect(1));
        test = "Lists";
        isSelected=true;
      }
      if (index == 2) {
      
        test = "Share";
      }
      if (index == 3) {
      
        test="Profile";
      }
      
    }
   

    Widget widgetlist = buildTestableWidget(BottomBar(onItemSelected(1)));
    await tester.pumpWidget(widgetlist);
    await tester.pump(new Duration(milliseconds: 1000));
    await tester.tap(find.text('Listes'));
    expect(find.byType(Function),findsOneWidget);
    
  });
}
