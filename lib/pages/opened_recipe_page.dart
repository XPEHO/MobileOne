import 'package:MobileOne/data/recipe.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/recipeItems_provider.dart';
import 'package:MobileOne/providers/recipes_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
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
  var _analytics = GetIt.I.get<AnalyticsService>();
  final _myController = TextEditingController();
  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnOpenedRecipePage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Recipe _recipe = ModalRoute.of(context).settings.arguments;
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<RecipeItemsProvider>(),
      child: Consumer<RecipeItemsProvider>(
          builder: (context, recipeItemsProvider, child) {
        if (_recipe != null && _recipe.label != null) {
          _myController.text = _recipe.label;
        }
        return content(recipeItemsProvider.getRecipeItems(_recipe.recipeUuid),
            _recipe.recipeUuid);
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
            return (recipeItems.length > 0)
                ? buildRecipe(context, recipeItems, _recipeUuid)
                : emptyRecipe();
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
        onTap: () => _myController.selection = TextSelection(
            baseOffset: 0, extentOffset: _myController.text.length),
        focusNode: _nameFocusNode,
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
      actions: [
        popupMenuButton(),
      ],
    );
  }

  PopupMenuButton<int> popupMenuButton() {
    return PopupMenuButton<int>(
      key: Key("recipeMenu"),
      itemBuilder: (context) => [
        PopupMenuItem(
          key: Key("renameRecipe"),
          value: 1,
          child: Text(getString(context, 'rename')),
        ),
      ],
      icon: Icon(Icons.more_vert, color: WHITE),
      onSelected: (value) {
        switch (value) {
          case 1:
            _analytics.sendAnalyticsEvent("renameARecipe");
            _nameFocusNode.requestFocus();
            _myController.selection = TextSelection(
                baseOffset: 0, extentOffset: _myController.text.length);
            break;
        }
      },
    );
  }

  Widget buildRecipe(BuildContext context, List<WishlistItem> recipeItems,
      String _recipeUuid) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: Column(
        children: [
          Icon(
            Icons.local_dining,
            color: WHITE,
            size: 64,
          ),
          Expanded(
            child: ListView.builder(
                padding:
                    EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
                itemCount: recipeItems.length,
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
                    child: buildItem(context, _recipeUuid, recipeItems, index),
                    onDismissed: (direction) {
                      deleteItemFromRecipe(
                          recipeUuid: _recipeUuid,
                          itemUuid: recipeItems[index].uuid,
                          imageName: recipeItems[index].imageName);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Padding buildItem(BuildContext context, String _recipeUuid,
      List<WishlistItem> recipeItems, int index) {
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
              leading: getItemImage(recipeItems[index].imageUrl),
              trailing: Icon(
                Icons.navigate_next,
                color: BLACK,
              ),
            ),
          ),
        ),
      ),
    );
  }

  buildDeleteShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_item_deletion')),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(getString(context, 'delete_item'))),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
  }

  void deleteItemFromRecipe(
      {String recipeUuid, String itemUuid, String imageName}) {
    GetIt.I.get<RecipeItemsProvider>().deleteItemInRecipe(
        recipeUuid: recipeUuid, itemUuid: itemUuid, imageName: imageName);
  }

  dynamic getItemImage(String url) {
    if (url != null) {
      return url == "assets/images/canned-food.png"
          ? Icon(
              Icons.photo_camera,
              size: 32,
            )
          : Image(image: NetworkImage(url));
    } else {
      return Icon(
        Icons.photo_camera,
        size: 32,
      );
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            "assets/images/square-logo.png",
            height: 100,
            width: 100,
          ),
          Icon(Icons.add_shopping_cart, size: 64, color: WHITE),
          Text(
            getString(context, "empty_items"),
            style: TextStyle(color: WHITE, fontSize: 20),
          ),
        ],
      ),
    );
  }

  void openItemPage(
      String buttonName, String recipeUuid, String itemUuid, bool isRecipe) {
    Navigator.of(context).pushNamed('/createItem',
        arguments: ItemArguments(listUuid: recipeUuid, itemUuid: itemUuid));
  }

  void closePage() {
    Navigator.pop(context);
  }
}
