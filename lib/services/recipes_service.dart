import 'package:MobileOne/dao/recipes_dao.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class RecipesService {
  final RecipesDao dao = GetIt.I.get<RecipesDao>();
  final UserService userService = GetIt.I.get<UserService>();

  Map<String, dynamic> _recipes = {};
  Map<String, List<WishlistItem>> _recipeItems = {};

  void _flush() {
    _recipes = {};
  }

  Map<String, dynamic> get recipes => _recipes;

  Future<Map<String, dynamic>> fetchRecipes() async {
    DocumentSnapshot recipes = await dao.fetchRecipes(userService.user.uid);
    var data;
    if (recipes?.data() == null) {
      data = Map<String, dynamic>();
    } else {
      data = recipes.data() ?? Map<String, dynamic>();
    }
    _recipes = data;
    return data;
  }

  addRecipe(BuildContext context) async {
    final recipeUuid = Uuid().v4();
    await dao.addRecipe(recipeUuid, userService.user.uid, context);
    _flush();
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
}
