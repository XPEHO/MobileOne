import 'package:MobileOne/services/recipes_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecipesProvider with ChangeNotifier {
  final recipesService = GetIt.I.get<RecipesService>();

  Map<String, dynamic> get recipes {
    final recipes = recipesService.recipes;
    if (recipes == null || recipes.isEmpty) {
      recipesService.fetchRecipes().then((value) => notifyListeners());
    }
    return recipes;
  }

  addRecipe(BuildContext context) async {
    await recipesService.addRecipe(context);
    notifyListeners();
  }

  changeRecipeLabel(String label, String recipeUuid) async {
    recipesService.changeRecipeLabel(label, recipeUuid);
    notifyListeners();
  }
}
