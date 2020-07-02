import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class WishlistsListProvider with ChangeNotifier {
  final UserService userService = GetIt.I.get<UserService>();

  Future<DocumentSnapshot> get ownerLists {
    return Firestore.instance
        .collection("owners")
        .document(userService.user.uid)
        .get();
  }

  addWishlist(String text) async {
    bool doesListExist = false;
    final newUuid = Uuid().v4();

    //Create a wishlist
    await Firestore.instance.collection("wishlists").document(newUuid).setData({
      'itemCounts': "0",
      'label': text,
      'timestamp': new DateTime.now(),
    });

    //Check if the user already have a wishlist
    await Firestore.instance
        .collection("owners")
        .document(UserService().user.uid)
        .get()
        .then((value) {
      doesListExist = value.exists;
    });

    //Create the document and set document's data to the new wishlist if the user does not have an existing wishlist
    //Or get the already existing wishlists, add the new one to the list and update the list in the database
    if (doesListExist) {
      await Firestore.instance
          .collection("owners")
          .document(UserService().user.uid)
          .updateData({
        "lists": FieldValue.arrayUnion(["$newUuid"])
      });
    } else {
      await Firestore.instance
          .collection("owners")
          .document(UserService().user.uid)
          .setData({
        "lists": ["$newUuid"]
      });
    }
    notifyListeners();
  }
}
