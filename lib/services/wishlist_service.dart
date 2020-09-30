import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/data/owner_details.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/messaging_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class WishlistService {
  final WishlistDao dao = GetIt.I.get<WishlistDao>();
  final MessagingService messagingService = GetIt.I.get<MessagingService>();
  final UserService userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();

  Map<String, Wishlist> _wishlists = {};
  Map<String, List<WishlistItem>> _itemlists = {};
  Map<String, dynamic> _shareLists = {};
  Map<String, dynamic> _ownerLists = {};
  Map<String, dynamic> _guestLists = {};
  Map<String, OwnerDetails> _ownerDetails = {};
  List<Categories> _categories = [];

  void _flush() {
    _wishlists = {};
    _itemlists = {};
    _shareLists = {};
    _ownerLists = {};
    _guestLists = {};
    _ownerDetails = {};
    _categories = [];
  }

  List get ownerLists => _ownerLists[userService.user.uid];

  Future<List> fetchOwnerLists() async {
    DocumentSnapshot ownerLists =
        await dao.fetchOwnerLists(userService.user.uid);
    List data;
    if (ownerLists?.data() == null) {
      data = List();
    } else {
      data = ownerLists.data()["lists"] ?? List();
    }
    _ownerLists[userService.user.uid] = data;
    return data;
  }

  guestLists(email) => _guestLists[email];

  Future<List> fetchGuestLists(String email) async {
    final guestLists = await dao.guestLists(email);
    var data;
    if (guestLists?.data() == null) {
      data = List();
    } else {
      data = guestLists.data()["lists"] ?? List();
    }
    _guestLists[email] = data;
    return data;
  }

  getSharelist() => _shareLists[userService.user.uid];

  Future<Map<String, dynamic>> fetchShareLists() async {
    DocumentSnapshot shareLists =
        await dao.fetchShareLists(userService.user.uid);
    var data;
    if (shareLists?.data() == null) {
      data = Map<String, dynamic>();
    } else {
      data = shareLists.data() ?? Map<String, dynamic>();
    }
    _shareLists[userService.user.uid] = data;
    return data;
  }

  addWishlist(BuildContext context) async {
    final wishlistUuid = Uuid().v4();
    await dao
        .addWishlist(wishlistUuid, userService.user.uid, userService.user.email)
        .whenComplete(() => Navigator.of(context).pushNamed('/openedListPage',
            arguments:
                OpenedListArguments(listUuid: wishlistUuid, isGuest: false)));
    _flush();
  }

  deleteWishlist(String listUuid, String userUid) async {
    _analytics.sendAnalyticsEvent("delete_wishlist");
    await dao.deleteWishlist(listUuid, userUid);
    _flush();
  }

  leaveShare(String listUuid, String email) async {
    _analytics.sendAnalyticsEvent("Leave_share");
    await dao.leaveShare(listUuid, email);
    _flush();
  }

  Future<Wishlist> fetchWishlist(String uuid) async {
    final wishlistData = await dao.fetchWishlist(uuid);

    if (wishlistData?.data() != null) {
      final wishlist = Wishlist.fromMap(uuid, wishlistData.data());
      _wishlists[uuid] = wishlist;
      return wishlist;
    }
    return null;
  }

  changeWishlistLabel(String label, String listUuid) async {
    label == null ? label = "" : label = label;
    dao.changeWishlistLabel(
        label, listUuid, userService.user.uid, userService.user.email);
    _wishlists[listUuid].label = label;
  }

  getwishlist(uuid) => _wishlists[uuid];

  List<WishlistItem> getItemList(String listUuid) =>
      sortItemsInList(_itemlists[listUuid]);

  Future<List<WishlistItem>> fetchItemList(String listUuid) async {
    DocumentSnapshot snapshot = await dao.fetchItemList(listUuid);

    final wishlist = snapshot?.data() ?? {};
    List<WishlistItem> itemList = wishlist.entries.map((element) {
      return WishlistItem.fromMap(element.key, element.value);
    }).toList();

    itemList = sortItemsInList(itemList);

    _itemlists[listUuid] = itemList;

    return itemList;
  }

  List<WishlistItem> sortItemsInList(List<WishlistItem> itemList) {
    if (itemList != null) {
      itemList.sort((a, b) {
        if (a.isValidated == b.isValidated) {
          if (a.label != null && b.label != null) {
            return a.label.toLowerCase().compareTo(b.label.toLowerCase());
          }
          return 0;
        } else if (a.isValidated) {
          return 1;
        } else {
          return -1;
        }
      });
    }

    return itemList;
  }

  addSharedToDataBase(String sharedWith, String liste) async {
    dao.addSharedToDataBase(sharedWith, liste, userService.user.uid);
    _analytics.sendAnalyticsEvent("user_shared_list");
    _flush();
  }

  addGuestToDataBase(String email, String listUuid) async {
    dao.addGuestToDataBase(email, listUuid);
    _flush();
  }

  deleteShared(String listUuid, String email) async {
    dao.deleteShared(listUuid, email, userService.user.uid);
    _analytics.sendAnalyticsEvent("delete_shared");
    _flush();
  }

  Future<void> addItemTolist({
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String listUuid,
    @required String imageName,
  }) async {
    var uuid = Uuid();
    var newUuid = uuid.v4();
    await dao.addItemTolist(
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        listUuid: listUuid,
        imageName: imageName,
        itemUuid: newUuid);
    await fetchItemList(listUuid);
  }

  Future<void> updateItemInList({
    @required String itemUuid,
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String listUuid,
    @required String imageName,
  }) async {
    dao.updateItemInList(
        itemUuid: itemUuid,
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        listUuid: listUuid,
        imageName: imageName);
    await fetchItemList(listUuid);
  }

  deleteItemInList({
    @required String listUuid,
    @required String itemUuid,
    @required String imageName,
  }) async {
    if (imageName != null) {
      GetIt.I.get<ImageService>().deleteFile(listUuid, imageName);
    }
    await dao.deleteItemInList(
        listUuid: listUuid, itemUuid: itemUuid, imageName: imageName);
    await fetchItemList(listUuid);
  }

  validateItem({
    @required String listUuid,
    @required String itemUuid,
    @required bool isValidated,
  }) async {
    dao.validateItem(
        listUuid: listUuid, itemUuid: itemUuid, isValidated: isValidated);
    await fetchItemList(listUuid);
  }

  List<dynamic> filterLists(String filterText) {
    return _wishlists.values
        .where((aList) => aList.label.toLowerCase().contains(filterText))
        .toList();
  }

  set wishlists(Map<String, Wishlist> wishlists) {
    _wishlists = wishlists;
  }

  uncheckAllItems({@required String listUuid}) async {
    await dao.uncheckAllItems(listUuid: listUuid);
    _flush();
  }

  flushWishlists() {
    _flush();
  }

  Future<void> addRecipeToList(String recipeUuid, String listUuid) async {
    await dao.addRecipeToList(recipeUuid, listUuid);
    await fetchItemList(listUuid);
  }

  setWishlistColor(String wishlistUuid, int color, bool flush) async {
    if (flush) {
      _wishlists[wishlistUuid].color = color;
    }
    await dao.setWishlistColor(wishlistUuid, color);
  }

  Future<OwnerDetails> getOwnerDetails(String listUuid) async {
    if (_ownerDetails.containsKey(listUuid)) {
      return _ownerDetails[listUuid];
    } else {
      OwnerDetails ownerDetails = await dao.getOwnerDetails(listUuid);
      _ownerDetails.addAll({listUuid: ownerDetails});
      return _ownerDetails[listUuid];
    }
  }

  List<Categories> getCategories() => _categories;

  Future<List<Categories>> fetchCategories(BuildContext context) async {
    _categories
        .add(Categories.fromMap(null, getString(context, "empty_category")));
    List<Map<String, dynamic>> map = await dao.getCategories();
    map.forEach((element) {
      switch (element["id"]) {
        case "78amWnyUJe3ekEs9FD53":
          _categories.add(Categories.fromMap(
              element["id"], getString(context, "recipy_category")));
          break;
        case "8jzs8g05JvvVQ87DI9wL":
          _categories.add(Categories.fromMap(
              element["id"], getString(context, "food_category")));
          break;
        default:
          _categories.add(Categories.fromMap(element["id"], element["label"]));
          break;
      }
    });

    return _categories;
  }

  changeWishlistCategory(String wishlistUuid, String categoryId) async {
    dao.changeWishlistCategory(wishlistUuid, categoryId);
    _wishlists[wishlistUuid].categoryId = categoryId;
  }

  List<List<Wishlist>> chunk(List<Wishlist> wishlists) {
    return wishlists
        .map((e) => e.categoryId)
        .toSet()
        .map((categoryId) => filterByCategory(wishlists, categoryId))
        .toList();
  }

  List<Wishlist> filterByCategory(List<Wishlist> wishlists, String categoryId) {
    return wishlists
        .where((element) => element.categoryId == categoryId)
        .toList();
  }
}
