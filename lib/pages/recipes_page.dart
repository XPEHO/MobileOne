import 'package:MobileOne/data/recipe.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/recipes_provider.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../localization/localization.dart';
import 'package:MobileOne/utility/colors.dart';

class RecipesPage extends StatefulWidget {
  RecipesPage({
    Key key,
  }) : super(key: key);

  @override
  RecipesPageState createState() => RecipesPageState();
}

class RecipesPageState extends State<RecipesPage> {
  var _colorsApp = GetIt.I.get<ColorService>();
  var _recipesProvider = GetIt.I.get<RecipesProvider>();
  var _itemsListProvider = GetIt.I.get<ItemsListProvider>();

  @override
  Widget build(BuildContext context) {
    String _listUuid = ModalRoute.of(context).settings.arguments;
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<RecipesProvider>(),
      child:
          Consumer<RecipesProvider>(builder: (context, recipesProvider, child) {
        return content(recipesProvider.recipes, _listUuid);
      }),
    );
  }

  Widget content(List<Recipe> recipes, String _listUuid) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _colorsApp.colorTheme,
          shadowColor: TRANSPARENT,
        ),
        backgroundColor: _colorsApp.colorTheme,
        floatingActionButton: FloatingActionButton(
          backgroundColor: _colorsApp.buttonColor,
          child: Icon(Icons.add),
          onPressed: () => createRecipe(),
        ),
        body: Builder(
          builder: (context) {
            if (recipes == null) {
              return Center(
                child: Text(getString(context, "loading")),
              );
            }
            return Column(
              children: <Widget>[
                Expanded(
                  child: (recipes.length > 0)
                      ? buildRecipes(context, recipes, _listUuid)
                      : emptyRecipes(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildRecipes(
      BuildContext context, List<Recipe> recipes, String _listUuid) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
          itemCount: recipes.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Dismissible(
              confirmDismiss: (DismissDirection direction) async {
                return await buildDeleteShowDialog(context);
              },
              background: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: RED,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.delete,
                          color: WHITE,
                        )),
                  ),
                ),
              ),
              secondaryBackground: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: RED,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.delete,
                          color: WHITE,
                        )),
                  ),
                ),
              ),
              key: UniqueKey(),
              child: buildRecipe(recipes, index, _listUuid),
              onDismissed: (direction) {
                _recipesProvider.deleteRecipe(recipes[index]);
              },
            );
          }),
    );
  }

  addRecipeToList(String recipeUuid, String listUuid) async {
    await _itemsListProvider.addRecipeToList(recipeUuid, listUuid);
    Navigator.of(context).pop();
  }

  Padding buildRecipe(List<Recipe> recipes, int index, String _listUuid) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: _colorsApp.greyColor,
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(recipes[index].label),
            leading: Icon(
              Icons.local_dining,
              size: 32.0,
            ),
            trailing: Wrap(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: BLACK,
                  ),
                  onPressed: () => openRecipePage(recipes[index]),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: BLACK,
                  ),
                  onPressed: () =>
                      addRecipeToList(recipes[index].recipeUuid, _listUuid),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  emptyRecipes() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            "assets/images/square-logo.png",
            height: 100,
            width: 100,
          ),
          Icon(Icons.local_dining, size: 100, color: WHITE),
          Text(
            getString(context, "empty_recipes"),
            style: TextStyle(color: WHITE, fontSize: 20),
          ),
        ],
      ),
    );
  }

  buildDeleteShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_recipe_deletion')),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(getString(context, 'delete_recipe'))),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
  }

  openRecipePage(Recipe recipe) {
    Navigator.pushNamed(context, "/openedRecipePage", arguments: recipe);
  }

  void createRecipe() async {
    await _recipesProvider.addRecipe(context);
  }

  void closePage() {
    Navigator.pop(context);
  }
}
