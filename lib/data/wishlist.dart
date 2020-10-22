import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist {
  String uuid;
  String label;
  String itemCount;
  int color;
  String _categoryId;
  Timestamp timestamp;
  Timestamp lastModification;
  int progression;

  Wishlist.fromMap(String uuid, Map<String, dynamic> properties) {
    this.uuid = uuid;
    this.label = properties["label"];
    this.itemCount = properties["itemCounts"];
    this.timestamp = properties["timestamp"];
    this.color = properties["color"];
    this.categoryId = properties["categoryId"];
    this.progression = properties["progression"];
    this.lastModification = properties["lastModification"];
  }

  set categoryId(String categoryId) {
    this._categoryId = categoryId;
  }

  get categoryId => _categoryId == null ? "0" : _categoryId;
}
