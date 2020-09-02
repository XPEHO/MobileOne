import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
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

  void _flush() {
    _wishlists = {};
    _itemlists = {};
    _shareLists = {};
    _ownerLists = {};
    _guestLists = {};
  }

  List get ownerLists => _ownerLists[userService.user.uid];

  Future<List> fetchOwnerLists() async {
    DocumentSnapshot ownerLists =
        await dao.fetchOwnerLists(userService.user.uid);
    var data;
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
      data = Map();
    } else {
      data = shareLists.data() ?? Map();
    }
    _shareLists[userService.user.uid] = data;
    return data;
  }

  addWishlist(BuildContext context) async {
    final wishlistUuid = Uuid().v4();
    await dao.addWishlist(wishlistUuid, userService.user.uid).whenComplete(() =>
        Navigator.of(context).pushNamed('/openedListPage',
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
    dao.changeWishlistLabel(label, listUuid);
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
      itemList.sort((a, b) => a.label.compareTo(b.label));
      itemList.sort((a, b) =>
          a.isValidated.toString().compareTo(b.isValidated.toString()));
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
}
