import 'package:MobileOne/data/wishlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WishlistHeadProvider with ChangeNotifier {
  Map<String, Wishlist> _wishlists = {};

  void fetchWishlist(String uuid) async {
    debugPrint("fetch wishlist head from firebase");
    final wishlist =
        await Firestore.instance.collection("wishlists").document(uuid).get();

    if (wishlist?.data != null) {
      _wishlists[uuid] = Wishlist.fromMap(uuid, wishlist.data);
      notifyListeners();
    } else {
      debugPrint("unable to fetch wishlist with uuid $uuid");
    }
  }

  Wishlist getWishlist(uuid) => _wishlists[uuid];
}
