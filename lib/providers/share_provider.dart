import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareProvider with ChangeNotifier {
  final wishlistService = GetIt.I.get<WishlistService>();

  List get ownerLists {
    final ownerLists = wishlistService.ownerLists;
    if (ownerLists == null) {
      wishlistService.fetchOwnerLists().then((value) => notifyListeners());
    }
    return ownerLists;
  }

  Map<String, dynamic> get shareLists {
    Map<String, dynamic> shareLists = wishlistService.getSharelist();
    if (shareLists == null) {
      wishlistService.fetchShareLists().whenComplete(() => notifyListeners());
    }
    return shareLists;
  }

  addSharedToDataBase(String sharedWith, String liste) async {
    wishlistService.addSharedToDataBase(sharedWith, liste);
    notifyListeners();
  }

  addGuestToDataBase(String uuidUser, String list) async {
    wishlistService.addGuestToDataBase(uuidUser, list);
    notifyListeners();
  }

  deleteShared(String listUuid, String email) async {
    wishlistService.deleteShared(listUuid, email);
    notifyListeners();
  }
}
