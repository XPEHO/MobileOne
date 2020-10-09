import 'dart:collection';

class WishlistItem {
  String uuid;
  String imageUrl;
  bool isValidated;
  String label;
  int quantity;
  int unit;
  String imageName;
  int order = 0;

  WishlistItem();

  WishlistItem.fromMap(String uuid, Map<String, dynamic> map) {
    this.uuid = uuid;
    this.imageUrl = map["image"];
    this.isValidated = map["isValidated"];
    this.label = map["label"];
    this.quantity = map["quantity"];
    this.unit = map["unit"];
    this.imageName = map["imageName"];
    this.order = map["order"] ?? 0;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = new HashMap<String, dynamic>();
    map["image"] = this.imageUrl;
    map["isValidated"] = this.isValidated;
    map["label"] = this.label;
    map["quantity"] = this.quantity;
    map["unit"] = this.unit;
    map["imageName"] = this.imageName;
    map["order"] = this.order ?? 0;
    return map;
  }

  bool hasImage() => imageUrl != null && imageUrl.isNotEmpty;
}
