import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WishlistItemProvider with ChangeNotifier {
  WishlistService wishlistService = GetIt.I.get();

  var label = "";
  var quantity = 1;
  var _unit = 1;
  var _imageUrl;
  var _imageName;
  bool _isInitialised = false;

  void fetchItem(String listUuid, String itemUuid) {
    if (!_isInitialised) {
      var _item = itemUuid != null
          ? wishlistService
              .getItemList(listUuid)
              .where((element) => element.uuid == itemUuid)
              .first
          : emptyItem();

      label = _item.label;
      quantity = _item.quantity;
      _unit = _item.unit;
      _imageUrl = _item.imageUrl;
      _imageName = _item.imageName;
      _isInitialised = true;
    }
  }

  set audioLabel(value) {
    label = value;
    notifyListeners();
  }

  set scanLabel(value) {
    label = value;
    notifyListeners();
  }

  get imageName => _imageName;

  set imageName(String imageName) {
    _imageName = imageName;
    notifyListeners();
  }

  get imageUrl => _imageUrl;

  set imageUrl(imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  emptyItem() {
    var item = WishlistItem();
    item.label = "";
    item.quantity = 1;
    item.unit = 1;
    item.isValidated = false;
    item.imageUrl = null;
    item.imageName = null;
    return item;
  }

  get unit => _unit;

  set unit(int unit) {
    _unit = unit;
    notifyListeners();
  }

  Future<void> updateItemInList(String listUuid, String itemUuid) async {
    await wishlistService.updateItemInList(
        itemUuid: itemUuid,
        name: label,
        count: quantity,
        typeIndex: _unit,
        imageLink: _imageUrl,
        listUuid: listUuid,
        imageName: _imageName);
    _isInitialised = false;
    notifyListeners();
  }

  bool canValidate() {
    return label.isNotEmpty;
  }

  Future<void> addItemTolist(String listUuid) async {
    await wishlistService.addItemTolist(
        name: label,
        count: quantity,
        typeIndex: _unit,
        imageLink: _imageUrl,
        listUuid: listUuid,
        imageName: _imageName);
    _isInitialised = false;
    notifyListeners();
  }

  void increaseQuantity() {
    quantity += 1;
    notifyListeners();
  }

  bool canDecrement() => quantity > 1;

  void decreaseQuantity() {
    quantity -= 1;
    notifyListeners();
  }

  void uninitialise() {
    _isInitialised = false;
    notifyListeners();
  }
}
