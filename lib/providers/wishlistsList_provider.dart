import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/services/categories_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WishlistsListProvider with ChangeNotifier {
  final wishlistService = GetIt.I.get<WishlistService>();
  final categoriesService = GetIt.I.get<CategoriesService>();

  Map<String, List<Wishlist>> get ownerLists {
    final ownerLists = wishlistService.ownerLists;
    Map<String, List<Wishlist>> categories = {};
    if (ownerLists == null) {
      wishlistService.fetchOwnerLists().then((value) => notifyListeners());
    }
    if (ownerLists != null) {
      List<Wishlist> wishlistsList = [];
      ownerLists.forEach((element) {
        Wishlist wishlist = getWishlist(element);
        if (wishlist != null) {
          wishlistsList.add(wishlist);
        }
      });
      if (wishlistsList.isNotEmpty) {
        Map<String, List<Wishlist>> tmpCategories =
            wishlistService.chunk(wishlistsList);
        categories = wishlistService.sortByModification(tmpCategories);
      }
    }
    return categories;
  }

  Wishlist getWishlist(uuid) {
    Wishlist wishlist = wishlistService.getwishlist(uuid);
    if (wishlist == null) {
      wishlistService.fetchWishlist(uuid).whenComplete(() => notifyListeners());
    }
    return wishlist;
  }

  List guestLists(String email) {
    final guestLists = wishlistService.guestLists(email);
    if (guestLists == null) {
      wishlistService.fetchGuestLists(email).then((value) => notifyListeners());
    }
    return guestLists ?? List();
  }

  addWishlist(BuildContext context) async {
    await wishlistService.addWishlist(context);
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

  flushWishlists(String email) {
    wishlistService.fetchOwnerLists().then((value) => notifyListeners());
    wishlistService.fetchGuestLists(email).then((value) => notifyListeners());
  }

  List<Categories> getCategories(BuildContext context) {
    List<Categories> categories = categoriesService.getCategories();
    if (categories.isEmpty) {
      categoriesService.fetchCategories(context).then((value) {
        if (value != null) {
          categories = value;
        }
        notifyListeners();
      });
    }
    return categories;
  }

  changeWishlistCategory(String wishlistUuid, String categoryId) async {
    wishlistService.changeWishlistCategory(wishlistUuid, categoryId);
    notifyListeners();
  }

  setWishlistModificationTime(String wishlistUuid) {
    wishlistService.setWishlistModificationTime(wishlistUuid);
    notifyListeners();
  }
}
