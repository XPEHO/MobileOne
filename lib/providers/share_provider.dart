import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareProvider with ChangeNotifier {
  var userService = GetIt.I.get<UserService>();
  Future<DocumentSnapshot> get ownerLists {
    return Firestore.instance
        .collection("owners")
        .document(userService.user.uid)
        .get();
  }

  Future<DocumentSnapshot> get shareLists {
    return Firestore.instance
        .collection("shared")
        .document(userService.user.uid)
        .get();
  }

  addSharedToDataBase(String sharedWith, String liste) async {
    bool doesDocumentExist = false;
    await databaseReference
        .collection("shared")
        .document(userService.user.uid)
        .get()
        .then(
      (value) {
        doesDocumentExist = value.exists;
      },
    );

    if (doesDocumentExist == true) {
      await databaseReference
          .collection("shared")
          .document(userService.user.uid)
          .updateData(
        {
          liste: FieldValue.arrayUnion(
            ["$sharedWith"],
          )
        },
      );
    } else {
      await databaseReference
          .collection("shared")
          .document(userService.user.uid)
          .setData(
        {
          liste: FieldValue.arrayUnion(
            ["$sharedWith"],
          )
        },
      );
    }
    notifyListeners();
  }

  addGuestToDataBase(String uuidUser, String list) async {
    bool doesListExist = false;

    await Firestore.instance.collection("guests").document(uuidUser).get().then(
      (value) {
        doesListExist = value.exists;
      },
    );

    if (doesListExist) {
      await databaseReference
          .collection("guests")
          .document(uuidUser)
          .updateData(
        {
          "lists": FieldValue.arrayUnion(["$list"])
        },
      );
    } else {
      await databaseReference.collection("guests").document(uuidUser).setData(
        {
          "lists": FieldValue.arrayUnion(["$list"])
        },
      );
    }
    notifyListeners();
  }

  deleteShared(String listUuid, String email) async {
    await Firestore.instance.collection("guests").document(email).updateData({
      "lists": FieldValue.arrayRemove([listUuid])
    });

    await Firestore.instance
        .collection("shared")
        .document(UserService().user.uid)
        .updateData({
      listUuid: FieldValue.arrayRemove([email])
    });

    notifyListeners();
  }
}
