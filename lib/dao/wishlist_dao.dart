import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistDao {
  Future<DocumentSnapshot> fetchOwnerLists(String userUuid) =>
      Firestore.instance.collection("owners").document(userUuid).get();

  Future<DocumentSnapshot> guestLists(String email) =>
      Firestore.instance.collection("guests").document(email).get();

  Future<DocumentSnapshot> fetchShareLists(String userUuid) =>
      Firestore.instance.collection("shared").document(userUuid).get();

  addWishlist(String text, String wishlistUuid, String userUuid) async {
    //Create a wishlist
    await Firestore.instance
        .collection("wishlists")
        .document(wishlistUuid)
        .setData({
      'itemCounts': "0",
      'label': text,
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

  addGuestToDataBase(String uuidUser, String list) async {
    bool doesListExist = false;

    await Firestore.instance.collection("guests").document(uuidUser).get().then(
      (value) {
        doesListExist = value.exists;
      },
    );

    if (doesListExist) {
      await Firestore.instance
          .collection("guests")
          .document(uuidUser)
          .updateData(
        {
          "lists": FieldValue.arrayUnion(["$list"])
        },
      );
    } else {
      await Firestore.instance.collection("guests").document(uuidUser).setData(
        {
          "lists": FieldValue.arrayUnion(["$list"])
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
}
