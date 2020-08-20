import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WishlistsListProvider with ChangeNotifier {
  final wishlistService = GetIt.I.get<WishlistService>();

  Future<List> get ownerLists {
    return wishlistService.ownerLists;
  }

  Future<List> guestLists(String email) {
    return wishlistService.guestLists(email);
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
