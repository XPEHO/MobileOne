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
}
