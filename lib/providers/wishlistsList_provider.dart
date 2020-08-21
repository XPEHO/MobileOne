import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WishlistsListProvider with ChangeNotifier {
  final wishlistService = GetIt.I.get<WishlistService>();

  List get ownerLists {
    final ownerLists = wishlistService.ownerLists;
    if (ownerLists == null) {
      wishlistService.fetchOwnerLists().then((value) => notifyListeners());
    }
    return ownerLists;
  }

  List guestLists(String email) {
    final guestLists = wishlistService.guestLists(email);
    if (guestLists == null) {
      wishlistService.fetchGuestLists(email).then((value) => notifyListeners());
    }
    return guestLists ?? List();
  }

  addWishlist(String text) async {
    await wishlistService.addWishlist(text);
    notifyListeners();
  }

  deleteWishlist(String listUuid, String userUid) async {
    await wishlistService.deleteWishlist(listUuid, userUid);

    notifyListeners();
  }

  leaveShare(String listUuid, String email) async {
    await wishlistService.leaveShare(listUuid, email);
    notifyListeners();
  }
}
