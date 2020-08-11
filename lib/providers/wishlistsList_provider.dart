import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class WishlistsListProvider with ChangeNotifier {
  final UserService userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  Future<DocumentSnapshot> get ownerLists {
    return Firestore.instance
        .collection("owners")
        .document(userService.user.uid)
        .get();
  }

  Future<DocumentSnapshot> guestLists(String email) {
    return Firestore.instance.collection("guests").document(email).get();
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

  deleteWishlist(String listUuid, String userUid) async {
    _analytics.sendAnalyticsEvent("delete_wishlist");
    List tmpList = [];
    DocumentSnapshot tmpDoc;

    await Firestore.instance
        .collection("owners")
        .document(userUid)
        .get()
        .then((value) => tmpList = value.data["lists"]);

    tmpList.remove(listUuid);

    await Firestore.instance
        .collection("owners")
        .document(userUid)
        .updateData({"lists": tmpList});

    await Firestore.instance.collection("items").document(listUuid).delete();

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .delete();

    await Firestore.instance
        .collection("shared")
        .document(userUid)
        .get()
        .then((value) => tmpDoc = value);

    if (tmpDoc.data != null) {
      if (tmpDoc.data[listUuid] != null) {
        tmpDoc.data[listUuid].forEach((element) async {
          await Firestore.instance
              .collection("guests")
              .document(element)
              .updateData({
            "lists": FieldValue.arrayRemove([listUuid])
          });
        });
      }
    }

    Map<String, dynamic> newMap = tmpDoc.data;
    if (newMap != null) {
      newMap.remove(listUuid);

      await Firestore.instance
          .collection("shared")
          .document(userUid)
          .setData(newMap);
    }

    notifyListeners();
  }

  leaveShare(String listUuid, String email) async {
    _analytics.sendAnalyticsEvent("Leave_share");
    await Firestore.instance.collection("guests").document(email).updateData({
      "lists": FieldValue.arrayRemove([listUuid])
    });

    notifyListeners();
  }
}
