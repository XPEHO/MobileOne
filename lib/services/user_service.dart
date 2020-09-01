import 'package:MobileOne/services/preferences_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserService with ChangeNotifier {
  static User _user;
  final _prefService = GetIt.I.get<PreferencesService>();

  User get user {
    return _user;
  }

  set user(User user) {
    _user = user;
    notifyListeners();
  }

  Future<String> deleteAccount(User user) async {
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
    await FirebaseFirestore.instance
        .collection("owners")
        .doc(userUid)
        .get()
        .then((value) {
      if (value.data() != null) {
        tmpList = value.data()["lists"];
      }
    });

    if (tmpList != null) {
      tmpList.forEach((element) async {
        //Delete all list guests
        await FirebaseFirestore.instance
            .collection("shared")
            .doc(userUid)
            .get()
            .then((value) {
          if (value.data() != null) {
            tmpShare = value.data()[element];
          }
        });

        if (tmpShare != null) {
          tmpShare.forEach((email) async {
            await FirebaseFirestore.instance
                .collection("guests")
                .doc(email)
                .update({
              "lists": FieldValue.arrayRemove([element])
            });
          });
        }

        //Delete all user wishlists items
        await FirebaseFirestore.instance
            .collection("items")
            .doc(element)
            .delete();

        //Delete all wishlists
        await FirebaseFirestore.instance
            .collection("wishlists")
            .doc(element)
            .delete();
      });
    }

    //Delete user loyaltycards
    await FirebaseFirestore.instance
        .collection("loyaltycards")
        .doc(userUid)
        .delete();

    //Delete all wishlists shared with the user
    await FirebaseFirestore.instance
        .collection("guests")
        .doc(user.email)
        .delete();

    //Delete all user share
    await FirebaseFirestore.instance.collection("shared").doc(userUid).delete();

    //Delete all user wishlists
    await FirebaseFirestore.instance.collection("owners").doc(userUid).delete();
  }

  bool checkCurrentUser(String email, String password) {
    if (_prefService.getEmail() == email &&
        _prefService.getPassword() == password) {
      return true;
    }
    return false;
  }
}
