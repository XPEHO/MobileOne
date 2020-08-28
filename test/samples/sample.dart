import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

aWishlist({String label = "first", String itemCount = "0"}) {
  return Wishlist.fromMap(
    "",
    {
      "label": label,
      "itemCounts": itemCount,
      'timestamp': Timestamp(0, 0),
    },
  );
}

someWishlists(List<Wishlist> list) {
  Map<String, Wishlist> map = Map.fromIterable(list,
      key: (wishlist) => wishlist.uuid, value: (wishlist) => wishlist);
  return map;
}

WishlistItem aWishlistItem(
    {String imageUrl = "",
    bool isValidated = false,
    String label = "a",
    int quantity = 0,
    int unit = 0,
    String imageName = ""}) {
  return WishlistItem.fromMap(
    "",
    {
      "image": imageUrl,
      "isValidated": isValidated,
      "label": label,
      "quantity": quantity,
      "unit": unit,
      "imageName": imageName,
    },
  );
}
