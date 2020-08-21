class WishlistItem {
  String uuid;
  String imageUrl;
  bool isValidated;
  String label;
  int quantity;
  int unit;
  String imageName;

  WishlistItem();

  WishlistItem.fromMap(String uuid, Map<String, dynamic> map) {
    this.uuid = uuid;
    this.imageUrl = map["image"];
    this.isValidated = map["isValidated"];
    this.label = map["label"];
    this.quantity = map["quantity"];
    this.unit = map["unit"];
    this.imageName = map["imageName"];
  }
}
