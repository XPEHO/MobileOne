import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/widgets/widget_item.dart';
import 'package:MobileOne/widgets/widget_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    String listUuid = ModalRoute.of(context).settings.arguments;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: GetIt.I.get<WishlistHeadProvider>()),
        ChangeNotifierProvider.value(value: GetIt.I.get<ItemsListProvider>()),
      ],
      child: Consumer2<WishlistHeadProvider, ItemsListProvider>(
        builder: (context, wishlistHeadProvider, itemsListProvider, child) {
          return FutureBuilder<DocumentSnapshot>(
            future: itemsListProvider.fetchItemList(listUuid),
            builder: (context, snapshot) {
              return content(
                  wishlistHeadProvider.getWishlist(listUuid), snapshot.data);
            },
          );
        },
      ),
    );
  }

  List<WishlistItem> getSortedList(DocumentSnapshot snapshot) {
    final wishlist = snapshot?.data ?? {};
    final sortedList = wishlist.entries.map((element) {
      return WishlistItem.fromMap(element.key, element.value);
    }).toList();

    sortedList.sort((WishlistItem a, WishlistItem b) {
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
    return sortedList;
  }

  Widget content(Wishlist wishlistHead, DocumentSnapshot snapshot) {
    List<WishlistItem> wishlist = getSortedList(snapshot);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => EditItemPopup(
                  getString(context, 'popup_add'), wishlistHead.uuid, null));
        },
        child: Icon(Icons.add),
        backgroundColor: GREEN,
      ),
      appBar: AppBar(
        iconTheme: ThemeData.light().iconTheme,
        actionsIconTheme: ThemeData.light().iconTheme,
        textTheme: ThemeData.light().textTheme,
        backgroundColor: Colors.white,
        title: Center(child: Text(wishlistHead.label)),
        actions: <Widget>[
          PopupMenuButton(
            key: Key("wishlistMenu"),
            itemBuilder: (context) => [
              PopupMenuItem(
                key: Key("deleteItem"),
                value: 1,
                child: Text(getString(context, 'delete')),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(getString(context, 'share')),
              ),
            ],
            icon: Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 1:
                  confirmWishlistDeletion().then((value) async {
                    if (value == true) {
                      openListsPage();
                      GetIt.I.get<WishlistsListProvider>().deleteWishlist(
                          wishlistHead.uuid,
                          GetIt.I.get<UserService>().user.uid);
                    }
                  });
                  break;
                case 2:
                  askPermissions(wishlistHead.uuid);
                  break;
              }
            },
          )
        ],
      ),
      body: Builder(
        builder: (context) {
          if (wishlist.isEmpty) {
            return Center(
              child: Text(getString(context, "loading")),
            );
          }
          return SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: new ListView.builder(
                  padding: EdgeInsets.only(top: 30),
                  itemCount: wishlist.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Container(
                      child: Dismissible(
                          confirmDismiss: (DismissDirection direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await buildDeleteShowDialog(context);
                            } else {
                              return true;
                            }
                          },
                          background: Container(
                            color: GREEN,
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
                          secondaryBackground: Container(
                            color: RED,
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
                          key: UniqueKey(),
                          child: WidgetItem(wishlist[index], wishlistHead.uuid,
                              wishlist[index].uuid),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              deleteItemFromList(
                                listUuid: wishlistHead.uuid,
                                itemUuid: wishlist[index].uuid,
                              );
                            } else {
                              validateItem(
                                listUuid: wishlistHead.uuid,
                                item: wishlist[index],
                              );
                            }
                          }),
                    );
                  }),
            ),
          );
        },
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

  void deleteItemFromList({String listUuid, String itemUuid}) {
    GetIt.I
        .get<ItemsListProvider>()
        .deleteItemInList(listUuid: listUuid, itemUuid: itemUuid);
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
}
