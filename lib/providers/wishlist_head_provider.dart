import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WishlistHeadProvider with ChangeNotifier {
  final WishlistService wishlistService = GetIt.I.get<WishlistService>();

  changeWishlistLabel(String label, String listUuid) async {
    await wishlistService.changeWishlistLabel(label, listUuid);
    notifyListeners();
  }

  Wishlist getWishlist(uuid) {
    final wishlist = wishlistService.getwishlist(uuid);
    if (wishlist == null) {
      wishlistService.fetchWishlist(uuid).whenComplete(() => notifyListeners());
    }
    return wishlist;
  }

  List<dynamic> filteredLists(String filterText) {
    return wishlistService.filterLists(filterText);
  }

  setWishlistColor(String wishlistUuid, int color, bool flush) async {
    await wishlistService.setWishlistColor(wishlistUuid, color, true);
    notifyListeners();
  }

  setWishlistProgression(String wishlistUuid, int progression) async {
    await wishlistService.setWishlistProgression(wishlistUuid, progression);
    notifyListeners();
  }
}
