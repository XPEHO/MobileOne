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
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String listUuid;
  final _myController = TextEditingController();
  final _wishlistProvider = GetIt.I.get<WishlistHeadProvider>();
  var _colorsApp = GetIt.I.get<ColorService>();
  OpenedListArguments _args;
  List itemChecked = [];
  var currentValue;

  @override
  void initState() {
    _analytics.setCurrentPage("isOnOpenedListPage");
    super.initState();
  }

  void getvalidated(listUuid) async {
    List check = [];
    await Firestore.instance
        .collection("items")
        .document(_args.listUuid)
        .get()
        .then((value) {
      if (value.data != null) {
        value.data.keys.forEach((element) {
          if (value.data[element]["isValidated"] == true) {
            check.add(value.data[element]["isValidated"]);
          }
        });
        itemChecked = check;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _args = Arguments.value(context);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: GetIt.I.get<ItemsListProvider>()),
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

  List<WishlistItem> getSortedList(List<WishlistItem> items) {
    items.sort((WishlistItem a, WishlistItem b) {
      final isAValidate = a.isValidated;
      final isBValidate = b.isValidated;
      if (isAValidate == isBValidate) {
        return 0;
      } else if (isAValidate) {
        return 1;
      } else {
        return -1;
      }
    });
    return items;
  }

  Widget content(Wishlist wishlistHead, List<WishlistItem> items) {
    return SafeArea(
      child: Scaffold(
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
            List<WishlistItem> wishlist = getSortedList(items);
            getvalidated(listUuid); // FIXME
            var pourcentage =
                (wishlist.isNotEmpty) ? (100 / wishlist.length) : 0;
            currentValue = (itemChecked.length == wishlist.length &&
                    pourcentage.toInt() * itemChecked.length != 100)
                ? pourcentage.toInt() * itemChecked.length +
                    100 -
                    pourcentage.toInt() * itemChecked.length
                : pourcentage.toInt() * itemChecked.length;
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: WHITE,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: TextField(
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
                        ),
                        Flexible(
                            flex: 1,
                            child: PopupMenuButton(
                              key: Key("wishlistMenu"),
                              itemBuilder: (context) => _args.isGuest
                                  ? [
                                      PopupMenuItem(
                                        key: Key("leaveShare"),
                                        value: 3,
                                        child: Text(
                                            getString(context, 'leave_share')),
                                      )
                                    ]
                                  : [
                                      PopupMenuItem(
                                        key: Key("deleteItem"),
                                        value: 1,
                                        child:
                                            Text(getString(context, 'delete')),
                                      ),
                                      PopupMenuItem(
                                        value: 2,
                                        child:
                                            Text(getString(context, 'share')),
                                      ),
                                    ],
                              icon: Icon(Icons.more_horiz, color: WHITE),
                              onSelected: (value) {
                                switch (value) {
                                  case 1:
                                    confirmWishlistDeletion()
                                        .then((value) async {
                                      if (value == true) {
                                        openListsPage();
                                        GetIt.I
                                            .get<WishlistsListProvider>()
                                            .deleteWishlist(
                                                wishlistHead.uuid,
                                                GetIt.I
                                                    .get<UserService>()
                                                    .user
                                                    .uid);
                                      }
                                    });
                                    break;
                                  case 2:
                                    _analytics.sendAnalyticsEvent(
                                        "share_list_from_openedlistpage");
                                    askPermissions(wishlistHead.uuid);
                                    break;
                                  case 3:
                                    confirmShareLeaving().then((value) async {
                                      if (value == true) {
                                        openListsPage();
                                        GetIt.I
                                            .get<WishlistsListProvider>()
                                            .leaveShare(
                                                wishlistHead.uuid,
                                                GetIt.I
                                                    .get<UserService>()
                                                    .user
                                                    .email);
                                      }
                                    });

                                    break;
                                }
                              },
                            )),
                      ],
                    ),
                    progressindicator(pourcentage),
                    (wishlist.length > 0)
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - 150,
                            child: new ListView.builder(
                                itemCount: wishlist.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return Container(
                                    child: Dismissible(
                                        confirmDismiss:
                                            (DismissDirection direction) async {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            return await buildDeleteShowDialog(
                                                context);
                                          } else {
                                            return true;
                                          }
                                        },
                                        background: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, left: 10),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: WHITE,
                                                  )),
                                            ),
                                          ),
                                        ),
                                        secondaryBackground: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, right: 10),
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    color: WHITE,
                                                  )),
                                            ),
                                          ),
                                        ),
                                        key: UniqueKey(),
                                        child: WidgetItem(
                                            wishlist[index],
                                            wishlistHead.uuid,
                                            wishlist[index].uuid),
                                        onDismissed: (direction) {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            deleteItemFromList(
                                                listUuid: wishlistHead.uuid,
                                                itemUuid: wishlist[index].uuid,
                                                imageName:
                                                    wishlist[index].imageName);
                                            _analytics.sendAnalyticsEvent(
                                                "delete_item");
                                          } else {
                                            validateItem(
                                              listUuid: wishlistHead.uuid,
                                              item: wishlist[index],
                                            );
                                            _analytics.sendAnalyticsEvent(
                                                "check_item");
                                          }
                                        }),
                                  );
                                }),
                          )
                        : emptyList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  emptyList() {
    return Column(
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
    );
  }

  Visibility progressindicator(num pourcentage) {
    return Visibility(
      visible: (itemChecked.length >= 1) ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FAProgressBar(
          currentValue: currentValue,
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

  void validateItem({String listUuid, WishlistItem item}) {
    GetIt.I.get<ItemsListProvider>().validateItem(
          listUuid: listUuid,
          itemUuid: item.uuid,
          isValidated: true,
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
