import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
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
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../localization/localization.dart';
import 'package:MobileOne/utility/colors.dart';

class OpenedListPage extends StatefulWidget {
  OpenedListPage({
    Key key,
  }) : super(key: key);

  @override
  OpenedListPageState createState() => OpenedListPageState();
}

class OpenedListPageState extends State<OpenedListPage> {
  var _analytics = GetIt.I.get<AnalyticsService>();

  final _myController = TextEditingController();
  final _wishlistProvider = GetIt.I.get<WishlistHeadProvider>();
  final _itemListProvider = GetIt.I.get<ItemsListProvider>();
  var _colorsApp = GetIt.I.get<ColorService>();
  OpenedListArguments _args;

  var currentValue;

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
            final wishlistHeadProvider = GetIt.I.get<WishlistHeadProvider>();
            Wishlist wishlist =
                wishlistHeadProvider.getWishlist(_args.listUuid);
            _myController.text = wishlist?.label ?? "";
            return content(
                wishlist, itemsListProvider.getItemList(_args.listUuid));
          });
        },
      ),
    );
  }

  Widget content(Wishlist wishlistHead, List<WishlistItem> items) {
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBar(context, wishlistHead),
        backgroundColor: _colorsApp.colorTheme,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            openItemPage(
                getString(context, 'popup_add'), wishlistHead.uuid, null);
          },
          child: Icon(Icons.add),
          backgroundColor: _colorsApp.buttonColor,
        ),
        body: Builder(
          builder: (context) {
            if (items == null) {
              return Center(
                child: Text(getString(context, "loading")),
              );
            }

            return Column(
              children: <Widget>[
                progressindicator(),
                Expanded(
                  child: (items.length > 0)
                      ? buildList(context, items, wishlistHead)
                      : emptyList(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildList(BuildContext context, List<WishlistItem> wishlist,
      Wishlist wishlistHead) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 64),
          itemCount: wishlist.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return Container(
              child: Dismissible(
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await buildDeleteShowDialog(context);
                    } else {
                      await validateItem(
                        listUuid: wishlistHead.uuid,
                        item: wishlist[index],
                      );
                      _analytics.sendAnalyticsEvent("check_item");
                      return false;
                    }
                  },
                  background: Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: GREEN,
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check,
                              color: WHITE,
                            )),
                      ),
                    ),
                  ),
                  secondaryBackground: Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 10),
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
                  child: WidgetItem(
                      wishlist[index], wishlistHead.uuid, wishlist[index].uuid),
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      deleteItemFromList(
                          listUuid: wishlistHead.uuid,
                          itemUuid: wishlist[index].uuid,
                          imageName: wishlist[index].imageName);
                      _analytics.sendAnalyticsEvent("delete_item");
                    }
                  }),
            );
          }),
    );
  }

  AppBar buildAppBar(BuildContext context, Wishlist wishlistHead) {
    return AppBar(
        backgroundColor: _colorsApp.colorTheme,
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
            _wishlistProvider.changeWishlistLabel(
                _myController.text, wishlistHead.uuid);
          },
        ),
        actions: [
          popupMenuButton(wishlistHead),
        ]);
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
              )
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
        }
      },
    );
  }

  emptyList() {
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
    PermissionStatus permissionStatus = await _getContactPermission();

    if (permissionStatus != PermissionStatus.granted) {
      openedListsPage();
    } else {
      openSharePage(uuid);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
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

  void openItemPage(String buttonName, String listUuid, String itemUuid) {
    Navigator.of(context).pushNamed('/createItem',
        arguments: ItemArguments(
            buttonName: buttonName, listUuid: listUuid, itemUuid: itemUuid));
  }
}
