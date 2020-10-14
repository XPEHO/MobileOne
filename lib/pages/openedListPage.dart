import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/permissions/permissions.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/widgets/widget_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';
import '../localization/localization.dart';
import 'package:MobileOne/utility/colors.dart';

class OpenedListPage extends StatefulWidget {
  OpenedListPage({
    Key key,
  }) : super(key: key);

  @override
  OpenedListPageState createState() => OpenedListPageState();
}

class OpenedListPageState extends State<OpenedListPage>
    with SingleTickerProviderStateMixin {
  var _analytics = GetIt.I.get<AnalyticsService>();

  final _myController = TextEditingController();
  final _wishlistProvider = GetIt.I.get<WishlistHeadProvider>();
  final _wishlistsListProvider = GetIt.I.get<WishlistsListProvider>();
  final _itemListProvider = GetIt.I.get<ItemsListProvider>();
  var _colorsApp = GetIt.I.get<ColorService>();
  OpenedListArguments _args;

  var currentValue;

  bool isOpened = false;
  ColorSwatch _selectedColor;
  final _nameFocusNode = FocusNode();

  List<Categories> _categories = [];
  Color _appBarColor;

  @override
  void initState() {
    _analytics.setCurrentPage("isOnOpenedListPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _args = Arguments.value(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _itemListProvider),
      ],
      child: Consumer<ItemsListProvider>(
        builder: (context, itemsListProvider, child) {
          return Builder(builder: (context) {
            _categories = _wishlistsListProvider.getCategories(context);
            final wishlistHeadProvider = GetIt.I.get<WishlistHeadProvider>();
            Wishlist wishlist =
                wishlistHeadProvider.getWishlist(_args.listUuid);
            if (wishlist != null && wishlist.color != null) {
              _appBarColor = Color(wishlist.color);
            } else {
              _appBarColor = _colorsApp.colorTheme;
            }
            _myController.text = wishlist?.label ?? "";
            return content(
                wishlist,
                itemsListProvider.getItemList(_args.listUuid),
                itemsListProvider);
          });
        },
      ),
    );
  }

  Widget content(Wishlist wishlistHead, List<WishlistItem> items, provider) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: _colorsApp.colorTheme,
        floatingActionButton: buildFloatingActionButton(wishlistHead),
        body: CustomScrollView(
          slivers: <Widget>[
            buildAppBar(context, wishlistHead),
            buildList(context, items, wishlistHead, provider),
          ],
        ),
      ),
    );
  }

  Widget buildFloatingActionButton(Wishlist wishlistHead) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          child: FloatingActionButton(
              heroTag: "Button 1",
              backgroundColor: _colorsApp.buttonColor,
              child: Icon(Icons.add),
              onPressed: () {
                openItemPage(wishlistHead.uuid, null);
              }),
        ),
      ],
    );
  }

  Widget buildList(BuildContext context, List<WishlistItem> items,
      Wishlist wishlistHead, ItemsListProvider provider) {
    var listItems = buildListItems(wishlistHead, items);
    return listItems.length > 0
        ? ReorderableSliverList(
            delegate: ReorderableSliverChildListDelegate(listItems),
            onReorder: (int oldIndex, int newIndex) {
              provider.onReorder(wishlistHead.uuid, oldIndex, newIndex);
            },
          )
        : SliverToBoxAdapter(
            child: emptyList(),
          );
  }

  List<Widget> buildListItems(wishlistHead, List<WishlistItem> items) {
    if (items == null) {
      return List.generate(1, (index) => Text(getString(context, "loading")));
    }
    return List.generate(
        items.length, (index) => buildListItem(wishlistHead, items, index));
  }

  Widget buildListItem(wishlistHead, items, index) {
    return Container(
      child: Dismissible(
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart) {
              return await buildDeleteShowDialog(context);
            } else {
              await validateItem(
                listUuid: wishlistHead.uuid,
                item: items[index],
              );
              _analytics.sendAnalyticsEvent("check_item");
              return false;
            }
          },
          background: Container(
            decoration: BoxDecoration(
              color: GREEN,
              borderRadius: BorderRadius.all(
                Radius.circular(0),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Icon(
                    Icons.check,
                    color: WHITE,
                  )),
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: RED,
              borderRadius: BorderRadius.all(
                Radius.circular(0),
              ),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: Icon(
                    Icons.delete,
                    color: WHITE,
                  )),
            ),
          ),
          key: UniqueKey(),
          child: WidgetItem(items[index], wishlistHead.uuid, items[index].uuid),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              deleteItemFromList(
                  listUuid: wishlistHead.uuid,
                  itemUuid: items[index].uuid,
                  imageName: items[index].imageName);
              _analytics.sendAnalyticsEvent("delete_item");
            }
          }),
    );
  }

  void openColorPicker(Widget content, String wishlistUuid) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(getString(context, "picker_title")),
          content: content,
          actions: [
            FlatButton(
              child: Text(getString(context, "picker_cancel")),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FlatButton(
              child: Text(getString(context, "picker_submit")),
              onPressed: () {
                _analytics.sendAnalyticsEvent("changeWishlistColor");
                Navigator.of(context).pop();
                _wishlistProvider.setWishlistColor(
                    wishlistUuid, _selectedColor.value, true);
              },
            ),
          ],
        );
      },
    ).whenComplete(() {
      setState(() {
        _appBarColor = _selectedColor;
      });
    });
  }

  Widget buildAppBar(BuildContext context, Wishlist wishlistHead) {
    return SliverAppBar(
      backgroundColor: _appBarColor,
      pinned: true,
      floating: true,
      expandedHeight: 120,
      title: _args.isGuest
          ? Center(
              child: Text(
                _myController.text,
                style: TextStyle(
                  color: WHITE,
                ),
              ),
            )
          : TextField(
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
                _wishlistProvider.changeWishlistLabel(
                    _myController.text, wishlistHead.uuid);
              },
            ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          alignment: Alignment.bottomCenter,
          height: 100,
          child: buildDropDownMenu(wishlistHead),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () {
            openColorPicker(
              MaterialColorPicker(
                selectedColor: _selectedColor,
                allowShades: false,
                onMainColorChange: (color) =>
                    setState(() => _selectedColor = color),
              ),
              wishlistHead.uuid,
            );
          },
          child: Icon(
            Icons.color_lens,
            color: WHITE,
          ),
        ),
        popupMenuButton(wishlistHead),
      ],
    );
  }

  Widget buildDropDownMenu(Wishlist wishlist) {
    String _type;

    if (wishlist != null &&
        wishlist.categoryId != null &&
        wishlist.categoryId != "0") {
      _type = _categories
          .where((element) => element.id == wishlist.categoryId)
          .first
          .label;
    } else {
      _type = _categories.where((element) => element.id == null).first.label;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 96.0, vertical: 8.0),
      child: DropdownButton<String>(
        iconEnabledColor: WHITE,
        dropdownColor: _appBarColor,
        hint: Text(
          getString(context, 'item_type'),
        ),
        onChanged: (text) {
          setState(() {
            _type = text;
            _wishlistsListProvider.changeWishlistCategory(
                wishlist.uuid,
                _categories
                    .where((element) => element.label == _type)
                    .first
                    .id);
          });
        },
        value: _type,
        items: _categories.map((Categories value) {
          return new DropdownMenuItem<String>(
            value: value.label,
            child: new Text(value.label,
                style: TextStyle(color: WHITE, fontSize: 18)),
          );
        }).toList(),
      ),
    );
  }

  PopupMenuButton<int> popupMenuButton(Wishlist wishlistHead) {
    return PopupMenuButton<int>(
      key: Key("wishlistMenu"),
      itemBuilder: (context) => _args.isGuest
          ? [
              PopupMenuItem(
                value: 4,
                child: Text(getString(context, 'restart_wishlist')),
              ),
              PopupMenuItem(
                key: Key("leaveShare"),
                value: 3,
                child: Text(getString(context, 'leave_share')),
              ),
            ]
          : [
              PopupMenuItem(
                key: Key("deleteItem"),
                value: 1,
                child: Text(getString(context, 'delete')),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(getString(context, 'share')),
              ),
              PopupMenuItem(
                key: Key("restartWishlist"),
                value: 4,
                child: Text(getString(context, 'restart_wishlist')),
              ),
              PopupMenuItem(
                key: Key("renameWishlist"),
                value: 5,
                child: Text(getString(context, 'rename')),
              ),
            ],
      icon: Icon(Icons.more_vert, color: WHITE),
      onSelected: (value) {
        switch (value) {
          case 1:
            confirmWishlistDeletion().then((value) async {
              if (value == true) {
                openListsPage();
                GetIt.I.get<WishlistsListProvider>().deleteWishlist(
                    wishlistHead.uuid, GetIt.I.get<UserService>().user.uid);
              }
            });
            break;
          case 2:
            _analytics.sendAnalyticsEvent("share_list_from_openedlistpage");
            askPermissions(wishlistHead.uuid);
            break;
          case 3:
            confirmShareLeaving().then((value) async {
              if (value == true) {
                openListsPage();
                GetIt.I.get<WishlistsListProvider>().leaveShare(
                    wishlistHead.uuid, GetIt.I.get<UserService>().user.email);
              }
            });
            break;
          case 4:
            confirmWishlistRestart(wishlistHead.uuid);
            break;
          case 5:
            _nameFocusNode.requestFocus();
            _myController.selection = TextSelection(
                baseOffset: 0, extentOffset: _myController.text.length);
            break;
        }
      },
    );
  }

  emptyList() {
    return Container(
      height: MediaQuery.of(context)
          .size
          .height, //Fixed size make the keyboard reload the screen
      child: Center(
        child: Column(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Image.asset(
                "assets/images/square-logo.png",
                height: 100,
                width: 100,
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Icon(Icons.add_shopping_cart, size: 100, color: WHITE),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
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

  Visibility progressindicator() {
    int progress = GetIt.I.get<ItemsListProvider>().progress(_args.listUuid);
    return Visibility(
      visible: (progress > 0) ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FAProgressBar(
          currentValue: progress,
          displayText: '%',
          changeColorValue: 0,
          changeProgressColor: _colorsApp.buttonColor,
        ),
      ),
    );
  }

  Future<bool> buildDeleteShowDialog(BuildContext context) {
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

  void deleteItemFromList(
      {String listUuid, String itemUuid, String imageName}) {
    GetIt.I.get<ItemsListProvider>().deleteItemInList(
        listUuid: listUuid, itemUuid: itemUuid, imageName: imageName);
  }

  Future<void> validateItem({String listUuid, WishlistItem item}) async {
    await GetIt.I.get<ItemsListProvider>().validateItem(
          listUuid: listUuid,
          itemUuid: item.uuid,
          isValidated: true,
        );
  }

  Future<void> confirmWishlistRestart(String listUuid) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_wishlist_restart')),
          actions: <Widget>[
            FlatButton(
                key: Key("confirmWishlistRestart"),
                onPressed: () {
                  _itemListProvider.uncheckAllItems(listUuid: listUuid);
                  Navigator.of(context).pop();
                },
                child: Text(getString(context, 'confirm_restart_wishlist'))),
            FlatButton(
              key: Key("cancelWishlistRestart"),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
  }

  Future<bool> confirmWishlistDeletion() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_wishlist_deletion')),
          actions: <Widget>[
            FlatButton(
                key: Key("confirmWishlistDeletion"),
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
                child: Text(getString(context, 'delete_item'))),
            FlatButton(
              key: Key("cancelWishlistDeletion"),
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<bool> confirmShareLeaving() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_share_leaving')),
          actions: <Widget>[
            FlatButton(
                key: Key("confirmShareLeaving"),
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
                child: Text(getString(context, 'confirm_leave'))),
            FlatButton(
              key: Key("cancelShareLeaving"),
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<void> askPermissions(Object uuid) async {
    PermissionStatus permissionStatus = await getContactPermission();

    if (permissionStatus != PermissionStatus.granted) {
      openedListsPage();
    } else {
      openSharePage(uuid);
    }
  }

  void openedListsPage() {
    Navigator.popUntil(context, ModalRoute.withName('/openedListPage'));
  }

  void openListsPage() {
    Navigator.pop(context);
  }

  void openSharePage(Object uuid) {
    Navigator.of(context)
        .pushNamed('/shareOne', arguments: ShareArguments(previousList: uuid));
  }

  void openRecipesPage(String listUuid) {
    Navigator.of(context).pushNamed('/recipes', arguments: listUuid);
  }

  openItemPage(String listUuid, String itemUuid) async {
    var created = await Navigator.of(context).pushNamed('/createItem',
        arguments: ItemArguments(listUuid: listUuid, itemUuid: itemUuid));
    if (created) {
      _itemListProvider.fireUpdate();
    }
  }
}
