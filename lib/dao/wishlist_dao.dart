import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WishlistDao {
  Future<DocumentSnapshot> fetchOwnerLists(String userUuid) =>
      Firestore.instance.collection("owners").document(userUuid).get();

  Future<DocumentSnapshot> guestLists(String email) =>
      Firestore.instance.collection("guests").document(email).get();

  Future<DocumentSnapshot> fetchShareLists(String userUuid) =>
      Firestore.instance.collection("shared").document(userUuid).get();

  Future<void> addWishlist(String wishlistUuid, String userUuid) async {
    String wishlistName;

    await Firestore.instance
        .collection("owners")
        .document(userUuid)
        .get()
        .then((value) {
      value.data.isNotEmpty
          ? wishlistName =
              "Wishlist " + (value.data["lists"].length + 1).toString()
          : wishlistName = "Wishlist 1";
    });

    //Create a wishlist
    await Firestore.instance
        .collection("wishlists")
        .document(wishlistUuid)
        .setData({
      'itemCounts': "0",
      'label': wishlistName,
      'timestamp': new DateTime.now(),
    });

    //Check if the user already have a wishlist
    final owners =
        await Firestore.instance.collection("owners").document(userUuid).get();
    bool doesListExist = owners?.exists;

    //Create the document and set document's data to the new wishlist if the user does not have an existing wishlist
    //Or get the already existing wishlists, add the new one to the list and update the list in the database
    if (doesListExist) {
      await Firestore.instance
          .collection("owners")
          .document(userUuid)
          .updateData({
        "lists": FieldValue.arrayUnion(["$wishlistUuid"])
      });
    } else {
      await Firestore.instance.collection("owners").document(userUuid).setData(
        {
          "lists": ["$wishlistUuid"]
        },
      );
    }
  }

  deleteWishlist(String listUuid, String userUid) async {
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
  }

  leaveShare(String listUuid, String email) =>
      Firestore.instance.collection("guests").document(email).updateData({
        "lists": FieldValue.arrayRemove([listUuid])
      });

  Future<DocumentSnapshot> fetchWishlist(String uuid) =>
      Firestore.instance.collection("wishlists").document(uuid).get();

  changeWishlistLabel(String label, String listUuid) =>
      Firestore.instance.collection("wishlists").document(listUuid).setData(
        {
          "label": label,
        },
        merge: true,
      );

  Future<DocumentSnapshot> fetchItemList(String listUuid) {
    return Firestore.instance.collection('items').document(listUuid).get();
  }

  addSharedToDataBase(String sharedWith, String liste, String userUuid) async {
    final shared =
        await Firestore.instance.collection("shared").document(userUuid).get();
    bool doesDocumentExist = shared.exists;

    if (doesDocumentExist == true) {
      await Firestore.instance
          .collection("shared")
          .document(userUuid)
          .updateData(
        {
          liste: FieldValue.arrayUnion(
            ["$sharedWith"],
          )
        },
      );
    } else {
      await Firestore.instance.collection("shared").document(userUuid).setData(
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

    await Firestore.instance.collection("guests").document(email).get().then(
      (value) {
        doesListExist = value.exists;
      },
    );

    if (doesListExist) {
      await Firestore.instance.collection("guests").document(email).updateData(
        {
          "lists": FieldValue.arrayUnion(["$listUuid"])
        },
      );
    } else {
      await Firestore.instance.collection("guests").document(email).setData(
        {
          "lists": FieldValue.arrayUnion(["$listUuid"])
        },
      );
    }
  }

  deleteShared(String listUuid, String email, String userUuid) async {
    await Firestore.instance.collection("guests").document(email).updateData({
      "lists": FieldValue.arrayRemove([listUuid])
    });

    await Firestore.instance
        .collection("shared")
        .document(userUuid)
        .updateData({
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

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .get()
        .then((value) {
      listItemsCount = value["itemCounts"];
    });

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .updateData({"itemCounts": (int.parse(listItemsCount) + 1).toString()});

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .get()
        .then((value) {
      doesDocumentExist = value.exists;
    });

    //Create the item
    if (doesDocumentExist == true) {
      await Firestore.instance
          .collection("items")
          .document(listUuid)
          .updateData({
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
      await Firestore.instance.collection("items").document(listUuid).setData({
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
    @required String itemUuid,
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String listUuid,
    @required String imageName,
  }) async {
    await Firestore.instance.collection("items").document(listUuid).updateData({
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

  Future<void> deleteItemInList({
    @required String listUuid,
    @required String itemUuid,
    @required String imageName,
  }) async {
    var listItemsCount;

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .get()
        .then((value) {
      listItemsCount = value["itemCounts"];
    });

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .updateData({"itemCounts": (int.parse(listItemsCount) - 1).toString()});

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .updateData({itemUuid: FieldValue.delete()});
  }

  Future<void> validateItem({
    @required String listUuid,
    @required String itemUuid,
    @required bool isValidated,
  }) async {
    await Firestore.instance.collection("items").document(listUuid).setData(
      {
        itemUuid: {
          'isValidated': isValidated,
        }
      },
      merge: true,
    );
  }

  uncheckAllItems({@required String listUuid}) async {
    Map<String, dynamic> tmpMap;

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .get()
        .then((value) => tmpMap = value.data);

    tmpMap.forEach((key, value) {
      value["isValidated"] = false;
    });

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .setData(tmpMap);
  }
}
