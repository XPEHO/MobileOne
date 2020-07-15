import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ItemsListProvider with ChangeNotifier {
  String _listUuid;

  set listUuid(String uuid) {
    _listUuid = uuid;
    notifyListeners();
  }

  String get listUuid {
    return _listUuid;
  }

  Future<DocumentSnapshot> get itemsList {
    return Firestore.instance.collection('items').document(listUuid).get();
  }

  addItemTolist(
      String _name, int _count, String _type, String _imageLink) async {
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
          'label': _name,
          'quantity': _count,
          'unit': _type,
          'image': _imageLink,
        }
      });
    } else {
      await Firestore.instance.collection("items").document(listUuid).setData({
        newUuid: {
          'label': _name,
          'quantity': _count,
          'unit': _type,
          'image': _imageLink,
        }
      });
    }
    notifyListeners();
  }

  updateItemInList(String itemUuid, String _name, int _count, String _type,
      String _imageLink) async {
    await Firestore.instance.collection("items").document(listUuid).updateData({
      itemUuid: {
        'label': _name,
        'quantity': _count,
        'unit': _type,
        'image': _imageLink,
      }
    });
    notifyListeners();
  }

  deleteItemInList(String itemUuid) async {
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
        .document(_listUuid)
        .updateData({itemUuid: FieldValue.delete()});
    notifyListeners();
  }
}
