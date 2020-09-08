import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/recipes_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecipeItemsProvider with ChangeNotifier {
  final recipesService = GetIt.I.get<RecipesService>();

  List<WishlistItem> getRecipeItems(String recipeUuid) {
    List<WishlistItem> recipeItems = recipesService.getRecipeItems(recipeUuid);
    if (recipeItems == null || recipeItems.isEmpty) {
      recipesService
          .fetchRecipeItems(recipeUuid)
          .whenComplete(() => notifyListeners());
    }
    return recipeItems;
  }

  Future<void> addItemToRecipe({
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String recipeUuid,
    @required String imageName,
  }) async {
    await recipesService.addItemToRecipe(
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        recipeUuid: recipeUuid,
        imageName: imageName);
    notifyListeners();
  }

  Future<void> updateItemInRecipe({
    @required String itemUuid,
    @required String name,
    @required int count,
    @required int typeIndex,
    @required String imageLink,
    @required String recipeUuid,
    @required String imageName,
  }) async {
    await recipesService.updateItemInRecipe(
        itemUuid: itemUuid,
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        recipeUuid: recipeUuid,
        imageName: imageName);
    notifyListeners();
  }
}
