import 'package:MobileOne/data/wishlist.dart';
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
