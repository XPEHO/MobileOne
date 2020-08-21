import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/delegate.dart';
import 'package:MobileOne/localization/supported.dart';
import 'package:MobileOne/pages/openedListPage.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:MobileOne/services/loyalty_cards_service.dart';
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

class AnalyticsServiceMock extends Mock implements AnalyticsService {}

class ColorServiceMock extends Mock implements ColorService {}

class ShareServiceMock extends Mock implements ShareService {}

class LoyaltyCardsServiceMock extends Mock implements LoyaltyCardsService {}

class LoyaltyCardsProvidermock extends Mock implements LoyaltyCardsProvider {}

void main() {
  setSupportedLocales([Locale('fr', 'FR')]);

  testWidgets('The wishlist menu should find deletion widget',
      (WidgetTester tester) async {
    //Given
    final _itemsListProvider = MockItemsListProvider();
    final _wishlistHeadProvider = MockWishlistHeadProvider();
    GetIt.I.registerSingleton<ItemsListProvider>(_itemsListProvider);
    GetIt.I.registerSingleton<WishlistHeadProvider>(_wishlistHeadProvider);
    final _analyticsService = AnalyticsServiceMock();
    GetIt.I.registerSingleton<AnalyticsService>(_analyticsService);

    final _colorService = ColorServiceMock();
    GetIt.I.registerSingleton<ColorService>(_colorService);
    final _shareService = ShareServiceMock();
    GetIt.I.registerSingleton<ShareService>(_shareService);
    final _loyaltycardsService = LoyaltyCardsServiceMock();
    GetIt.I.registerSingleton<LoyaltyCardsService>(_loyaltycardsService);
    final _loyaltycardsProvider = LoyaltyCardsProvider();
    GetIt.I.registerSingleton<LoyaltyCardsProvider>(_loyaltycardsProvider);

    final wishlist = MockWishlist();
    when(wishlist.label).thenReturn("test");
    when(_wishlistHeadProvider.getWishlist(any)).thenReturn(wishlist);
    when(_itemsListProvider.getItemList(any)).thenReturn(List());

    final mockArguments = MockArguments();
    Arguments.proxy = mockArguments;
    when(mockArguments.get(any)).thenReturn(OpenedListArguments(
      listUuid: "",
      isGuest: false,
    ));

    //When
    await tester.pumpWidget(buildTestableWidget(new OpenedListPage()));
    await tester.pumpAndSettle(Duration(seconds: 2));

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
