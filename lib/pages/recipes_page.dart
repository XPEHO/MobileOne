import 'package:MobileOne/localization/localization.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<RecipesProvider>(),
      child:
          Consumer<RecipesProvider>(builder: (context, recipesProvider, child) {
        return content(recipesProvider.recipes);
      }),
    );
  }

  Widget content(Map<String, dynamic> recipes) {
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
                      ? buildRecipes(context, recipes)
                      : emptyRecipes(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildRecipes(BuildContext context, Map<String, dynamic> recipes) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
          itemCount: recipes.length,
          itemBuilder: (BuildContext ctxt, int index) {
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
                    title: Text(recipes.values.toList()[index]["label"]),
                    leading: SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(Icons.note_add),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: BLACK,
                      ),
                      onPressed: () =>
                          openRecipePage(recipes.keys.toList()[index]),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  emptyRecipes() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Image.asset(
                "assets/images/square-logo.png",
                height: 100,
                width: 100,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Icon(Icons.note_add, size: 100, color: WHITE),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Text(
                getString(context, "empty_recipes"),
                style: TextStyle(color: WHITE, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  openRecipePage(String recipeUuid) {
    Navigator.pushNamed(context, "/openedRecipePage", arguments: recipeUuid);
  }

  void createRecipe() async {
    await _recipesProvider.addRecipe(context);
  }

  void closePage() {
    Navigator.pop(context);
  }
}
