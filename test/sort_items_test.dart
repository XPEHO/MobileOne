import 'package:MobileOne/dao/messaging_dao.dart';
import 'package:MobileOne/dao/user_dao.dart';
import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'samples/sample.dart';

void main() {
  group('Items sort tests', () {
    //Given
    GetIt.I.registerSingleton<WishlistDao>(WishlistDao());
    GetIt.I.registerSingleton<PreferencesService>(PreferencesService());
    GetIt.I.registerSingleton<UserDao>(UserDao());
    GetIt.I.registerSingleton(UserService());
    GetIt.I.registerSingleton<MessagingDao>(MessagingDao());
    GetIt.I.registerSingleton<MessagingService>(MessagingService());
    GetIt.I.registerSingleton(AnalyticsService());

    final service = WishlistService();

    test("Sort the items in a wishlist by label", () {
      //Given
      List<WishlistItem> list = [
        aWishlistItem(label: "z"),
        aWishlistItem(label: "a"),
        aWishlistItem(label: "u"),
        aWishlistItem(label: "M"),
        aWishlistItem(label: "B"),
      ];

      //When
      List<WishlistItem> result = service.sortItemsInList(list);

      //Then
      expect(result == null, false);
      expect(result.isNotEmpty, true);
      expect(result.first.label == "a", true);
      expect(result.last.label == "z", true);
    });

    test("Sort the items in a wishlist by order", () {
      //Given
      List<WishlistItem> list = [
        aWishlistItem(label: "a", order: 2),
        aWishlistItem(label: "b", order: 1),
      ];

      //When
      List<WishlistItem> result = service.sortItemsInList(list);

      //Then
      expect(result == null, false);
      expect(result.isNotEmpty, true);
      expect(result.first.label == "b", true);
      expect(result.last.label == "a", true);
    });

    test("Sort the items in a wishlist by validation", () {
      //Given
      List<WishlistItem> list = [
        aWishlistItem(label: "", isValidated: false),
        aWishlistItem(label: "", isValidated: true),
        aWishlistItem(label: "", isValidated: false),
      ];

      //When
      List<WishlistItem> result = service.sortItemsInList(list);

      //Then
      expect(result == null, false);
      expect(result.isNotEmpty, true);
      expect(result.first.isValidated, false);
      expect(result.last.isValidated, true);
    });

    test("Sort the items in a wishlist by label and validation", () {
      //Given
      List<WishlistItem> list = [
        aWishlistItem(label: "z", isValidated: false),
        aWishlistItem(label: "a", isValidated: false),
        aWishlistItem(label: "u", isValidated: false),
        aWishlistItem(label: "M", isValidated: true),
        aWishlistItem(label: "B", isValidated: true),
      ];

      //When
      List<WishlistItem> result = service.sortItemsInList(list);

      //Then
      expect(result == null, false);
      expect(result.isNotEmpty, true);
      expect(result.first.label == "a", true);
      expect(result.first.isValidated, false);
      expect(result[result.length - 2].label == "B", true);
      expect(result[result.length - 2].isValidated, true);
      expect(result.last.label == "M", true);
      expect(result.last.isValidated, true);
    });
  });
}
