import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDao {
  Future<void> deleteUserData(String userUid, User user) async {
    List tmpList = [];
    List tmpShare = [];
    List tmpRecipes = [];

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

    //Get all user recipes
    await FirebaseFirestore.instance
        .collection("recipes")
        .doc(userUid)
        .get()
        .then((value) {
      if (value.data() != null) {
        tmpRecipes = value.data().keys.toList();
      }
    });

    //Delete all recipes items
    tmpRecipes.forEach((element) async {
      await FirebaseFirestore.instance
          .collection("recipeItems")
          .doc(element)
          .delete();
    });

    //Delete all user recipes
    await FirebaseFirestore.instance
        .collection("recipes")
        .doc(userUid)
        .delete();

    //Delete user messaging token
    await FirebaseFirestore.instance
        .collection("appTokens")
        .doc(user.email)
        .delete();
  }
}
