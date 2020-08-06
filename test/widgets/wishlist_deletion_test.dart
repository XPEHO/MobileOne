import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/openedListPage.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
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

class MockItemsListProvider extends Mock implements ItemsListProvider {}

class MockWishlistHeadProvider extends Mock implements WishlistHeadProvider {}

class MockWishlist extends Mock implements Wishlist {}

class MockArguments extends Mock implements Arguments {}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('The wishlist menu should find deletion widget',
      (WidgetTester tester) async {
    //Given
    final _itemsListProvider = MockItemsListProvider();
    final _wishlistHeadProvider = MockWishlistHeadProvider();
    GetIt.I.registerSingleton<ItemsListProvider>(_itemsListProvider);
    GetIt.I.registerSingleton<WishlistHeadProvider>(_wishlistHeadProvider);

    final wishlist = MockWishlist();
    when(wishlist.label).thenReturn("test");
    when(_wishlistHeadProvider.getWishlist(any)).thenReturn(wishlist);

    final mockArguments = MockArguments();
    Arguments.proxy = mockArguments;
    when(mockArguments.get(any)).thenReturn(OpenedListArguments(
      listUuid: "",
      isGuest: false,
    ));

    await tester.pumpWidget(buildTestableWidget(new OpenedListPage()));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //When

    //Then
    expect(find.byKey(Key("wishlistMenu")), findsOneWidget);

    //When
    await tester.tap(find.byKey(Key("wishlistMenu")));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //Then
    expect(find.byKey(Key("deleteItem")), findsOneWidget);

    //When
    await tester.tap(find.byKey(Key("deleteItem")));
    await tester.pumpAndSettle(Duration(seconds: 2));

    //Then
    expect(find.byKey(Key("confirmWishlistDeletion")), findsOneWidget);
    expect(find.byKey(Key("cancelWishlistDeletion")), findsOneWidget);
  });
}
