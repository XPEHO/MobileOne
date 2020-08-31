import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'samples/sample.dart';

void main() {
  test("Sort the items in a wishlist", () {
    //Given
    GetIt.I.registerSingleton<WishlistDao>(WishlistDao());
    GetIt.I.registerSingleton<PreferencesService>(PreferencesService());
    GetIt.I.registerSingleton(UserService());
    GetIt.I.registerSingleton(AnalyticsService());

    final service = WishlistService();

    List<WishlistItem> list = [
      aWishlistItem(label: "b"),
      aWishlistItem(label: "c"),
      aWishlistItem(label: "a")
    ];

    //When
    List<WishlistItem> result = service.sortItemsInList(list);

    //Then
    expect(result == null, false);
    expect(result.isNotEmpty, true);
    expect(result.first.label == "a", true);
    expect(result.last.label == "c", true);
  });
}
