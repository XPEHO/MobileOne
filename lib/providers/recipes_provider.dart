import 'package:MobileOne/data/recipe.dart';
import 'package:MobileOne/services/recipes_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecipesProvider with ChangeNotifier {
  final recipesService = GetIt.I.get<RecipesService>();

  List<Recipe> get recipes {
    final recipes = recipesService.recipes;
    if (recipes == null) {
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

  deleteRecipe(Recipe recipe) async {
    await recipesService.deleteRecipe(recipe);
  }
}
