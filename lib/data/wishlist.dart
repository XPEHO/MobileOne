import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist {
  String uuid;
  String label;
  String itemCount;
  Timestamp timestamp;

  Wishlist.fromMap(String uuid, Map<String, dynamic> properties) {
    this.uuid = uuid;
    this.label = properties["label"];
    this.itemCount = properties["itemCounts"];
    this.timestamp = properties["timestamp"];
  }
}
