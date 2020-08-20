import 'package:MobileOne/dao/wishlist_dao.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class WishlistService {
  final WishlistDao dao = GetIt.I.get<WishlistDao>();
  final UserService userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();

  Map<String, Wishlist> _wishlists = {};
  Map<String, List<WishlistItem>> _itemlists = {};

  Future<List> get ownerLists async {
    DocumentSnapshot ownerLists =
        await dao.fetchOwnerLists(userService.user.uid);
    if (ownerLists?.data == null) {
      return List();
    } else {
      List data = ownerLists.data["lists"];
      return data ?? List();
    }
  }

  Future<List> guestLists(String email) async {
    final guestLists = await dao.guestLists(email);
    if (guestLists?.data == null) {
      return List();
    } else {
      List data = guestLists.data["lists"];
      return data ?? List();
    }
  }

  addWishlist(String text) async {
    final wishlistUuid = Uuid().v4();
    await dao.addWishlist(text, wishlistUuid, userService.user.uid);
  }

  deleteWishlist(String listUuid, String userUid) async {
    _analytics.sendAnalyticsEvent("delete_wishlist");
    await dao.deleteWishlist(listUuid, userUid);
  }

  leaveShare(String listUuid, String email) async {
    _analytics.sendAnalyticsEvent("Leave_share");
    await dao.leaveShare(listUuid, email);
  }

  Future<Wishlist> fetchWishlist(String uuid) async {
    final wishlistData = await dao.fetchWishlist(uuid);

    if (wishlistData?.data != null) {
      final wishlist = Wishlist.fromMap(uuid, wishlistData.data);
      _wishlists[uuid] = wishlist;
      return wishlist;
    }
    // TODO throw exception
    return null;
  }

  changeWishlistLabel(String label, String listUuid) async {
    label == null ? label = "" : label = label;
    await dao.changeWishlistLabel(label, listUuid);
    await fetchWishlist(listUuid);
  }

  getwishlist(uuid) => _wishlists[uuid];

  List<WishlistItem> getItemList(String listUuid) => _itemlists[listUuid];

  Future<List<WishlistItem>> fetchItemList(String listUuid) async {
    DocumentSnapshot snapshot = await dao.fetchItemList(listUuid);

    final wishlist = snapshot?.data ?? {};
    final itemList = wishlist.entries.map((element) {
      return WishlistItem.fromMap(element.key, element.value);
    }).toList();

    _itemlists[listUuid] = itemList;

    return itemList;
  }
}
