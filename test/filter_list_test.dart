import 'package:MobileOne/dao/messaging_dao.dart';
import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'samples/sample.dart';

void main() {
  test("Filter list when user is on step two of sharring a list", () {
    //Given
    GetIt.I.registerSingleton<WishlistDao>(WishlistDao());
    GetIt.I.registerSingleton<PreferencesService>(PreferencesService());
    GetIt.I.registerSingleton(UserService());
    GetIt.I.registerSingleton<MessagingDao>(MessagingDao());
    GetIt.I.registerSingleton<MessagingService>(MessagingService());
    GetIt.I.registerSingleton(AnalyticsService());

    final service = WishlistService();

    service.wishlists =
        someWishlists([aWishlist(label: "first"), aWishlist(label: "second")]);

    //When
    final result = service.filterLists("second");

    //Then
    expect(result == null, false);
    expect(result.isNotEmpty, true);
    expect(result.singleWhere((element) => element.label == "second") != null,
        true);
    expect(result.length, 1);
  });
}
