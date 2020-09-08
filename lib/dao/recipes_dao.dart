import 'package:MobileOne/localization/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RecipesDao {
  Future<DocumentSnapshot> fetchRecipes(String userUuid) =>
      FirebaseFirestore.instance.collection("recipes").doc(userUuid).get();

  Future<void> addRecipe(
      String recipeUuid, String userUuid, BuildContext context) async {
    String recipeName;

    await FirebaseFirestore.instance
        .collection("recipes")
        .doc(userUuid)
        .get()
        .then((value) {
      if (value.data() != null) {
        value.data().isNotEmpty
            ? recipeName = getString(context, "recipe_name") +
                (value.data().length + 1).toString()
            : recipeName = getString(context, "recipe_name") + "1";
      } else {
        recipeName = getString(context, "recipe_name") + "1";
      }
    });

    FirebaseFirestore.instance.collection("recipes").doc(userUuid).set(
      {
        "$recipeUuid": {
          'label': recipeName,
          'timestamp': new DateTime.now(),
        },
      },
      SetOptions(merge: true),
    );
  }

  Future<DocumentSnapshot> fetchRecipeItems(String recipeUuid) {
    return FirebaseFirestore.instance
        .collection('recipeItems')
        .doc(recipeUuid)
        .get();
  }

  Future<void> addItemToRecipe({
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String recipeUuid,
    @required String imageName,
    @required String itemUuid,
  }) async {
    bool doesDocumentExist = false;

    await FirebaseFirestore.instance
        .collection("recipeItems")
        .doc(recipeUuid)
        .get()
        .then((value) {
      doesDocumentExist = value.exists;
    });

    //Create the item
    if (doesDocumentExist == true) {
      await FirebaseFirestore.instance
          .collection("recipeItems")
          .doc(recipeUuid)
          .update({
        itemUuid: {
          'label': name,
          'quantity': count,
          'unit': typeIndex,
          'image': imageLink,
          'isValidated': false,
          'imageName': imageName,
        }
      });
    } else {
      await FirebaseFirestore.instance
          .collection("recipeItems")
          .doc(recipeUuid)
          .set({
        itemUuid: {
          'label': name,
          'quantity': count,
          'unit': typeIndex,
          'image': imageLink,
          'isValidated': false,
          'imageName': imageName,
        }
      });
    }
  }

  Future<void> updateItemInRecipe({
    @required String itemUuid,
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String recipeUuid,
    @required String imageName,
  }) async {
    await FirebaseFirestore.instance
        .collection("recipeItems")
        .doc(recipeUuid)
        .update({
      itemUuid: {
        'label': name,
        'quantity': count,
        'unit': typeIndex,
        'image': imageLink,
        'isValidated': false,
        'imageName': imageName,
      }
    });
  }

  changeRecipeLabel(String label, String recipeUuid, String userUuid) =>
      FirebaseFirestore.instance.collection("recipes").doc(userUuid).set(
        {
          recipeUuid: {
            "label": label,
          },
        },
        SetOptions(merge: true),
      );

  Future<DocumentSnapshot> fetchItemList(String listUuid) {
    return FirebaseFirestore.instance.collection('items').doc(listUuid).get();
  }
}
