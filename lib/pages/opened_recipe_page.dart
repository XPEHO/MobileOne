import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/recipeItems_provider.dart';
import 'package:MobileOne/providers/recipes_provider.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../localization/localization.dart';
import 'package:MobileOne/utility/colors.dart';

class OpenedRecipePage extends StatefulWidget {
  OpenedRecipePage({
    Key key,
  }) : super(key: key);

  @override
  OpenedRecipePageState createState() => OpenedRecipePageState();
}

class OpenedRecipePageState extends State<OpenedRecipePage> {
  var _colorsApp = GetIt.I.get<ColorService>();
  var _recipesProvider = GetIt.I.get<RecipesProvider>();
  final _myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String _recipeUuid = ModalRoute.of(context).settings.arguments;
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<RecipeItemsProvider>(),
      child: Consumer<RecipeItemsProvider>(
          builder: (context, recipeItemsProvider, child) {
        _myController.text = _recipesProvider.recipes[_recipeUuid]["label"];
        return content(
            recipeItemsProvider.getRecipeItems(_recipeUuid), _recipeUuid);
      }),
    );
  }

  Widget content(List<WishlistItem> recipeItems, String _recipeUuid) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(_recipeUuid),
        backgroundColor: _colorsApp.colorTheme,
        floatingActionButton: FloatingActionButton(
          backgroundColor: _colorsApp.buttonColor,
          child: Icon(Icons.add),
          onPressed: () => openItemPage(
              getString(context, 'popup_add'), _recipeUuid, null, true),
        ),
        body: Builder(
          builder: (context) {
            if (recipeItems == null) {
              return Center(
                child: Text(getString(context, "loading")),
              );
            }
            return Column(
              children: <Widget>[
                Expanded(
                  child: (recipeItems.length > 0)
                      ? buildRecipe(context, recipeItems, _recipeUuid)
                      : emptyRecipe(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar buildAppBar(String _recipeUuid) {
    return AppBar(
      backgroundColor: _colorsApp.colorTheme,
      shadowColor: TRANSPARENT,
      title: TextField(
        style: TextStyle(
          color: WHITE,
        ),
        controller: _myController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: getString(context, "wishlist_name"),
          hintStyle: TextStyle(color: _colorsApp.greyColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TRANSPARENT),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        onSubmitted: (_) {
          _recipesProvider.changeRecipeLabel(_myController.text, _recipeUuid);
        },
      ),
    );
  }

  Widget buildRecipe(BuildContext context, List<WishlistItem> recipeItems,
      String _recipeUuid) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
          itemCount: recipeItems.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => openItemPage(getString(context, 'popup_update'),
                    _recipeUuid, recipeItems[index].uuid, true),
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
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(getProductName(recipeItems[index].label)),
                          Text(getProductBrand(recipeItems[index].label)),
                        ],
                      ),
                      subtitle: Row(
                        children: <Widget>[
                          Text(
                              "x${recipeItems[index].quantity.toString()} ${getUnitText(recipeItems[index].unit)}"),
                        ],
                      ),
                      leading: Image(
                          image: getItemImage(recipeItems[index].imageUrl)),
                      trailing: Icon(
                        Icons.navigate_next,
                        color: BLACK,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  dynamic getItemImage(String url) {
    if (url != null) {
      return url == "assets/images/canned-food.png"
          ? AssetImage(url)
          : NetworkImage(url);
    } else {
      return AssetImage("assets/images/canned-food.png");
    }
  }

  String getUnitText(int unit) {
    switch (unit) {
      case 1:
        return getString(context, 'item_unit');
        break;
      case 2:
        return getString(context, 'item_liters');
        break;
      case 3:
        return getString(context, 'item_grams');
        break;
      case 4:
        return getString(context, 'item_kilos');
        break;
      default:
        return getString(context, 'item_unit');
        break;
    }
  }

  getProductBrand(String completeName) {
    if (completeName.contains('-')) {
      return completeName.substring(completeName.indexOf('-') + 1);
    }

    return "";
  }

  getProductName(String completeName) {
    if (completeName.contains('-')) {
      return completeName.substring(0, completeName.indexOf('-'));
    }
    return completeName;
  }

  emptyRecipe() {
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
              child: Icon(Icons.add_shopping_cart, size: 100, color: WHITE),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Text(
                getString(context, "empty_items"),
                style: TextStyle(color: WHITE, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openItemPage(
      String buttonName, String recipeUuid, String itemUuid, bool isRecipe) {
    Navigator.of(context).pushNamed('/createItem',
        arguments: ItemArguments(
            buttonName: buttonName,
            listUuid: recipeUuid,
            itemUuid: itemUuid,
            isRecipe: isRecipe));
  }

  void closePage() {
    Navigator.pop(context);
  }
}
