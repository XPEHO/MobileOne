import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class ItemsListProvider with ChangeNotifier {
  WishlistService wishlistService = GetIt.I.get<WishlistService>();

  List<WishlistItem> getItemList(String listUuid) {
    List<WishlistItem> itemList = wishlistService.getItemList(listUuid);
    if (itemList == null) {
      wishlistService
          .fetchItemList(listUuid)
          .whenComplete(() => notifyListeners());
    }
    return itemList;
  }

  Future<void> addItemTolist({
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String listUuid,
    @required String imageName,
  }) async {
    var uuid = Uuid();
    var newUuid = uuid.v4();
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
        newUuid: {
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
        newUuid: {
          'label': name,
          'quantity': count,
          'unit': typeIndex,
          'image': imageLink,
          'isValidated': false,
          'imageName': imageName,
        }
      });
    }

    notifyListeners();
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
    notifyListeners();
  }

  deleteItemInList({
    @required String listUuid,
    @required String itemUuid,
    @required String imageName,
  }) async {
    var listItemsCount;

    if (imageName != null) {
      GetIt.I.get<ImageService>().deleteFile(listUuid, imageName);
    }

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

  validateItem({
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
    notifyListeners();
  }
}
