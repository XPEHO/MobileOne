import 'package:MobileOne/dao/recipes_dao.dart';
import 'package:MobileOne/data/recipe.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import 'image_service.dart';

class RecipesService {
  final RecipesDao dao = GetIt.I.get<RecipesDao>();
  final UserService userService = GetIt.I.get<UserService>();

  List<Recipe> _recipes;
  Map<String, List<WishlistItem>> _recipeItems = {};

  void _flush() {
    _recipes = null;
  }

  List<Recipe> get recipes => _recipes;

  List<Recipe> sortRecipes(List<Recipe> recipiesList) {
    if (recipiesList != null) {
      recipiesList.sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    }

    return recipiesList;
  }

  Future<List<Recipe>> fetchRecipes() async {
    DocumentSnapshot snapshot = await dao.fetchRecipes(userService.user.uid);

    final recipes = snapshot?.data();

    if (recipes != null) {
      List<Recipe> recipesList = recipes.entries.map((element) {
        return Recipe.fromMap(element.key, element.value);
      }).toList();

      recipesList = sortRecipes(recipesList);

      _recipes = recipesList;
    }

    return _recipes;
  }

  addRecipe(BuildContext context) async {
    final recipeUuid = Uuid().v4();
    await dao.addRecipe(recipeUuid, userService.user.uid, context);
    await fetchRecipes().then((value) async {
      value.forEach((element) async {
        if (element.recipeUuid == recipeUuid) {
          await Navigator.of(context)
              .pushNamed("/openedRecipePage", arguments: element);
        }
      });
    });
  }

  List<WishlistItem> sortItemsInRecipe(List<WishlistItem> recipeItems) {
    if (recipeItems != null) {
      recipeItems.sort((a, b) {
        if (a.isValidated == b.isValidated) {
          return a.label.toLowerCase().compareTo(b.label.toLowerCase());
        } else if (a.isValidated) {
          return 1;
        } else {
          return -1;
        }
      });
    }

    return recipeItems;
  }

  List<WishlistItem> getRecipeItems(String recipeUuid) =>
      sortItemsInRecipe(_recipeItems[recipeUuid]);

  Future<List<WishlistItem>> fetchRecipeItems(String recipeUuid) async {
    DocumentSnapshot snapshot = await dao.fetchRecipeItems(recipeUuid);

    final recipe = snapshot?.data() ?? {};
    List<WishlistItem> recipeItems = recipe.entries.map((element) {
      return WishlistItem.fromMap(element.key, element.value);
    }).toList();

    recipeItems = sortItemsInRecipe(recipeItems);

    _recipeItems[recipeUuid] = recipeItems;

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
    var uuid = Uuid();
    var newUuid = uuid.v4();
    await dao.addItemToRecipe(
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        recipeUuid: recipeUuid,
        imageName: imageName,
        itemUuid: newUuid);
    await fetchRecipeItems(recipeUuid);
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
    dao.updateItemInRecipe(
        itemUuid: itemUuid,
        name: name,
        count: count,
        typeIndex: typeIndex,
        imageLink: imageLink,
        recipeUuid: recipeUuid,
        imageName: imageName);
    await fetchRecipeItems(recipeUuid);
  }

  changeRecipeLabel(String label, String recipeUuid) async {
    label == null ? label = "" : label = label;
    dao.changeRecipeLabel(label, recipeUuid, userService.user.uid);
    _flush();
  }

  deleteItemInRecipe({
    @required String recipeUuid,
    @required String itemUuid,
    @required String imageName,
  }) async {
    if (imageName != null) {
      GetIt.I.get<ImageService>().deleteFile(recipeUuid, imageName);
    }
    await dao.deleteItemInRecipe(
        recipeUuid: recipeUuid, itemUuid: itemUuid, imageName: imageName);
    await fetchRecipeItems(recipeUuid);
  }

  deleteRecipe(Recipe recipe) async {
    await dao.deleteRecipe(recipe.recipeUuid, userService.user.uid);
    if (_recipes != null) {
      _recipes.remove(recipe);
    }
  }

  flushRecipes() {
    _flush();
  }
}
