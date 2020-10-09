import 'package:MobileOne/data/owner_details.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WishlistDao {
  Future<DocumentSnapshot> fetchOwnerLists(String userUuid) =>
      FirebaseFirestore.instance.collection("owners").doc(userUuid).get();

  Future<DocumentSnapshot> guestLists(String email) =>
      FirebaseFirestore.instance.collection("guests").doc(email).get();

  Future<DocumentSnapshot> fetchShareLists(String userUuid) =>
      FirebaseFirestore.instance.collection("shared").doc(userUuid).get();

  Future<void> addWishlist(
      String wishlistUuid, String userUuid, String userEmail) async {
    String wishlistName;

    await FirebaseFirestore.instance
        .collection("owners")
        .doc(userUuid)
        .get()
        .then((value) {
      if (value.data() != null) {
        value.data().isNotEmpty
            ? wishlistName =
                "Wishlist " + (value.data()["lists"].length + 1).toString()
            : wishlistName = "Wishlist 1";
      } else {
        wishlistName = "Wishlist 1";
      }
    });

    //Create a wishlist
    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(wishlistUuid)
        .set({
      'itemCounts': "0",
      'label': wishlistName,
      'timestamp': new DateTime.now(),
      'owner': userUuid,
      'ownerEmail': userEmail,
    });

    //Check if the user already have a wishlist
    final owners = await FirebaseFirestore.instance
        .collection("owners")
        .doc(userUuid)
        .get();
    bool doesListExist = owners?.exists;

    //Create the document and set document's data to the new wishlist if the user does not have an existing wishlist
    //Or get the already existing wishlists, add the new one to the list and update the list in the database
    if (doesListExist) {
      await FirebaseFirestore.instance
          .collection("owners")
          .doc(userUuid)
          .update({
        "lists": FieldValue.arrayUnion(["$wishlistUuid"])
      });
    } else {
      await FirebaseFirestore.instance.collection("owners").doc(userUuid).set(
        {
          "lists": ["$wishlistUuid"]
        },
      );
    }
  }

  deleteWishlist(String listUuid, String userUid) async {
    List tmpList = [];
    DocumentSnapshot tmpDoc;

    await FirebaseFirestore.instance
        .collection("owners")
        .doc(userUid)
        .get()
        .then((value) => tmpList = value.data()["lists"]);

    tmpList.remove(listUuid);

    await FirebaseFirestore.instance
        .collection("owners")
        .doc(userUid)
        .update({"lists": tmpList});

    await FirebaseFirestore.instance.collection("items").doc(listUuid).delete();

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .delete();

    await FirebaseFirestore.instance
        .collection("shared")
        .doc(userUid)
        .get()
        .then((value) => tmpDoc = value);

    if (tmpDoc.data() != null) {
      if (tmpDoc.data()[listUuid] != null) {
        tmpDoc.data()[listUuid].forEach((element) async {
          await FirebaseFirestore.instance
              .collection("guests")
              .doc(element)
              .update({
            "lists": FieldValue.arrayRemove([listUuid])
          });
        });
      }
    }

    Map<String, dynamic> newMap = tmpDoc.data();
    if (newMap != null) {
      newMap.remove(listUuid);

      await FirebaseFirestore.instance
          .collection("shared")
          .doc(userUid)
          .set(newMap);
    }
  }

  leaveShare(String listUuid, String email) =>
      FirebaseFirestore.instance.collection("guests").doc(email).update({
        "lists": FieldValue.arrayRemove([listUuid])
      });

  Future<DocumentSnapshot> fetchWishlist(String uuid) =>
      FirebaseFirestore.instance.collection("wishlists").doc(uuid).get();

  changeWishlistLabel(
          String label, String listUuid, String userUid, String userEmail) =>
      FirebaseFirestore.instance.collection("wishlists").doc(listUuid).set(
        {
          "label": label,
          "owner": userUid,
          "ownerEmail": userEmail,
        },
        SetOptions(merge: true),
      );

  Future<DocumentSnapshot> fetchItemList(String listUuid) {
    return FirebaseFirestore.instance.collection('items').doc(listUuid).get();
  }

  addSharedToDataBase(String sharedWith, String liste, String userUuid) async {
    final shared = await FirebaseFirestore.instance
        .collection("shared")
        .doc(userUuid)
        .get();
    bool doesDocumentExist = shared.exists;

    if (doesDocumentExist == true) {
      await FirebaseFirestore.instance
          .collection("shared")
          .doc(userUuid)
          .update(
        {
          liste: FieldValue.arrayUnion(
            ["$sharedWith"],
          )
        },
      );
    } else {
      await FirebaseFirestore.instance.collection("shared").doc(userUuid).set(
        {
          liste: FieldValue.arrayUnion(
            ["$sharedWith"],
          )
        },
      );
    }
  }

  addGuestToDataBase(String email, String listUuid) async {
    bool doesListExist = false;

    await FirebaseFirestore.instance.collection("guests").doc(email).get().then(
      (value) {
        doesListExist = value.exists;
      },
    );

    if (doesListExist) {
      await FirebaseFirestore.instance.collection("guests").doc(email).update(
        {
          "lists": FieldValue.arrayUnion(["$listUuid"])
        },
      );
    } else {
      await FirebaseFirestore.instance.collection("guests").doc(email).set(
        {
          "lists": FieldValue.arrayUnion(["$listUuid"])
        },
      );
    }
  }

  deleteShared(String listUuid, String email, String userUuid) async {
    await FirebaseFirestore.instance.collection("guests").doc(email).update({
      "lists": FieldValue.arrayRemove([listUuid])
    });

    await FirebaseFirestore.instance.collection("shared").doc(userUuid).update({
      listUuid: FieldValue.arrayRemove([email])
    });
  }

  Future<void> addItemTolist({
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String listUuid,
    @required String imageName,
    @required String itemUuid,
  }) async {
    var listItemsCount;
    bool doesDocumentExist = false;

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .get()
        .then((value) {
      listItemsCount = value.data()["itemCounts"];
    });

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .update({"itemCounts": (int.parse(listItemsCount) + 1).toString()});

    await FirebaseFirestore.instance
        .collection("items")
        .doc(listUuid)
        .get()
        .then((value) {
      doesDocumentExist = value.exists;
    });

    //Create the item
    if (doesDocumentExist == true) {
      await FirebaseFirestore.instance
          .collection("items")
          .doc(listUuid)
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
      await FirebaseFirestore.instance.collection("items").doc(listUuid).set({
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

  Future<void> updateItemInList({
    @required String listUuid,
    @required WishlistItem item,
  }) async {
    await FirebaseFirestore.instance
        .collection("items")
        .doc(listUuid)
        .update({item.uuid: item.toMap()});
  }

  Future<void> deleteItemInList({
    @required String listUuid,
    @required String itemUuid,
    @required String imageName,
  }) async {
    var listItemsCount;

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .get()
        .then((value) {
      listItemsCount = value.data()["itemCounts"];
    });

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .update({"itemCounts": (int.parse(listItemsCount) - 1).toString()});

    await FirebaseFirestore.instance
        .collection("items")
        .doc(listUuid)
        .update({itemUuid: FieldValue.delete()});
  }

  Future<void> validateItem({
    @required String listUuid,
    @required String itemUuid,
    @required bool isValidated,
  }) async {
    await FirebaseFirestore.instance.collection("items").doc(listUuid).set(
      {
        itemUuid: {
          'isValidated': isValidated,
        }
      },
      SetOptions(merge: true),
    );
  }

  uncheckAllItems({@required String listUuid}) async {
    Map<String, dynamic> tmpMap;

    await FirebaseFirestore.instance
        .collection("items")
        .doc(listUuid)
        .get()
        .then((value) => tmpMap = value.data());

    tmpMap.forEach((key, value) {
      value["isValidated"] = false;
    });

    await FirebaseFirestore.instance
        .collection("items")
        .doc(listUuid)
        .set(tmpMap);
  }

  Future<void> addRecipeToList(String recipeUuid, String listUuid) async {
    Map<String, dynamic> recipeItemsMap;
    var listItemsCount;

    await FirebaseFirestore.instance
        .collection("recipeItems")
        .doc(recipeUuid)
        .get()
        .then((value) => recipeItemsMap = value.data());

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .get()
        .then((value) {
      listItemsCount = value.data()["itemCounts"];
    });

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .update({
      "itemCounts":
          (int.parse(listItemsCount) + recipeItemsMap.length).toString()
    });

    await FirebaseFirestore.instance.collection("items").doc(listUuid).set(
          recipeItemsMap,
          SetOptions(merge: true),
        );
  }

  setWishlistColor(String wishlistUuid, int color) async {
    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(wishlistUuid)
        .set(
      {
        "color": color,
      },
      SetOptions(merge: true),
    );
  }

  Future<OwnerDetails> getOwnerDetails(String listUuid) async {
    String ownerUid;
    String email;
    String path;

    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(listUuid)
        .get()
        .then((value) {
      if (value != null && value.data() != null) {
        if (value.data()["owner"] != null) {
          ownerUid = value.data()["owner"];
        }
        if (value.data()["ownerEmail"] != null) {
          email = value.data()["ownerEmail"];
        }
      }
    });

    if (ownerUid != null) {
      await FirebaseFirestore.instance
          .collection("userPicture")
          .doc(ownerUid)
          .get()
          .then((value) {
        if (value != null && value.data() != null) {
          if (value.data()["path"] != null) {
            path = value.data()["path"];
          }
        }
      });
    }

    return OwnerDetails.fromMap(path, email);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    List<Map<String, dynamic>> categories = [];

    await FirebaseFirestore.instance
        .collection("defaultCategories")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.data()["id"] != null && element.data()["label"] != null) {
          categories.add(element.data());
        }
      });
    });

    return categories;
  }

  Future<void> changeWishlistCategory(
      String wishlistUuid, String categoryId) async {
    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(wishlistUuid)
        .set(
      {
        "categoryId": categoryId,
      },
      SetOptions(merge: true),
    );
  }

  void updateItems(String listUuid, List<WishlistItem> items) async {
    var data = Map.fromEntries(items.map((e) => MapEntry(e.uuid, e.toMap())));
    await FirebaseFirestore.instance
        .collection("items")
        .doc(listUuid)
        .update(data);
  }

  setWishlistProgression(String wishlistUuid, int progression) async {
    await FirebaseFirestore.instance
        .collection("wishlists")
        .doc(wishlistUuid)
        .set(
      {
        "progression": progression,
      },
      SetOptions(merge: true),
    );
  }
}
