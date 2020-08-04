import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService with ChangeNotifier {
  static FirebaseUser _user;

  FirebaseUser get user {
    return _user;
  }

  set user(FirebaseUser user) {
    _user = user;
    notifyListeners();
  }

  Future<String> deleteAccount(FirebaseUser user) async {
    try {
      await user.delete();
      return "success";
    } catch (e) {
      return e.code;
    }
  }

  Future<void> deleteUserData(String userUid) async {
    List tmpList = [];
    List tmpShare = [];

    //Get all user wishlists
    await Firestore.instance
        .collection("owners")
        .document(userUid)
        .get()
        .then((value) {
      if (value.data != null) {
        tmpList = value.data["lists"];
      }
    });

    if (tmpList != null) {
      tmpList.forEach((element) async {
        //Delete all list guests
        await Firestore.instance
            .collection("shared")
            .document(userUid)
            .get()
            .then((value) {
          if (value.data != null) {
            tmpShare = value.data[element];
          }
        });

        if (tmpShare != null) {
          tmpShare.forEach((email) async {
            await Firestore.instance
                .collection("guests")
                .document(email)
                .updateData({
              "lists": FieldValue.arrayRemove([element])
            });
          });
        }

        //Delete all user wishlists items
        await Firestore.instance.collection("items").document(element).delete();

        //Delete all wishlists
        await Firestore.instance
            .collection("wishlists")
            .document(element)
            .delete();
      });
    }

    //Delete user loyaltycards
    await Firestore.instance
        .collection("loyaltycards")
        .document(userUid)
        .delete();

    //Delete all wishlists shared with the user
    await Firestore.instance.collection("guests").document(user.email).delete();

    //Delete all user share
    await Firestore.instance.collection("shared").document(userUid).delete();

    //Delete all user wishlists
    await Firestore.instance.collection("owners").document(userUid).delete();
  }
}
