import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ItemsListProvider with ChangeNotifier {
  WishlistService wishlistService = GetIt.I.get<WishlistService>();

  int progress(listUuid) {
    final itemLists = wishlistService.getItemList(listUuid);
    if (itemLists == null || itemLists.isEmpty) {
      return 0;
    }
    final validatedItems = itemLists.where((element) => element.isValidated);
    return ((100 * validatedItems.length) / itemLists.length).floor();
  }

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
    await wishlistService.addItemTolist(
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        listUuid: listUuid,
        imageName: imageName);
    notifyListeners();
  }

  deleteItemInList({
    @required String listUuid,
    @required String itemUuid,
    @required String imageName,
  }) async {
    if (imageName != null) {
      GetIt.I.get<ImageService>().deleteFile(listUuid, imageName);
    }
    await wishlistService.deleteItemInList(
        listUuid: listUuid, itemUuid: itemUuid, imageName: imageName);
    notifyListeners();
  }

  Future<void> validateItem({
    @required String listUuid,
    @required String itemUuid,
    @required bool isValidated,
  }) async {
    await wishlistService.validateItem(
        listUuid: listUuid, itemUuid: itemUuid, isValidated: isValidated);
    notifyListeners();
  }

  uncheckAllItems({@required String listUuid}) async {
    await wishlistService.uncheckAllItems(listUuid: listUuid);
    notifyListeners();
  }

  Future<void> addRecipeToList(String recipeUuid, String listUuid) async {
    await wishlistService.addRecipeToList(recipeUuid, listUuid);
    notifyListeners();
  }

  fireUpdate() {
    notifyListeners();
  }
}
