import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
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

String listUuid;
String label = "";

class OpenedListPage extends StatefulWidget {
  OpenedListPage({
    Key key,
  }) : super(key: key);

  @override
  OpenedListPageState createState() => OpenedListPageState();
}

class OpenedListPageState extends State<OpenedListPage> {
  String label = "";
  String listUuid = GetIt.I.get<ItemsListProvider>().listUuid;

  Future<void> getListTitle(String uuid) async {
    String labelValue;
    await Firestore.instance
        .collection("wishlists")
        .document(uuid)
        .get()
        .then((value) {
      labelValue = value["label"];
    });

    if (label == "") {
      setState(() {
        label = labelValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getListTitle(listUuid);
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<ItemsListProvider>(),
      child: Consumer<ItemsListProvider>(
        builder: (context, itemsListProvider, child) {
          return FutureBuilder<DocumentSnapshot>(
            future: itemsListProvider.itemsList,
            builder: (context, snapshot) {
              return content(snapshot.data);
            },
          );
        },
      ),
    );
  }

  Widget content(DocumentSnapshot snapshot) {
    final uuid = ModalRoute.of(context).settings.arguments;
    final wishlist = snapshot?.data ?? {};

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => EditItemPopup(
                  getString(context, 'popup_add'), listUuid, null));
        },
        child: Icon(Icons.add),
        backgroundColor: GREEN,
      ),
      appBar: AppBar(
        iconTheme: ThemeData.light().iconTheme,
        actionsIconTheme: ThemeData.light().iconTheme,
        textTheme: ThemeData.light().textTheme,
        backgroundColor: Colors.white,
        title: Center(child: Text(label)),
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
                          listUuid, GetIt.I.get<UserService>().user.uid);
                    }
                  });
                  break;
                case 2:
                  askPermissions(uuid);
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
                      color:
                          wishlist.values.toList()[index]["isValidated"] == true
                              ? GREEN
                              : TRANSPARENT,
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
                          child: WidgetItem(wishlist.values.toList()[index],
                              listUuid, wishlist.keys.toList()[index]),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              deleteItemFromList(wishlist.keys.toList()[index]);
                            } else {
                              validateItem(wishlist.values.toList()[index],
                                  wishlist.keys.toList()[index]);
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

  void deleteItemFromList(String uuid) {
    GetIt.I.get<ItemsListProvider>().deleteItemInList(uuid);
  }

  void validateItem(Map<String, dynamic> values, String itemUuid) {
    if (values["isValidated"] != null) {
      if (values["isValidated"] == true) {
        GetIt.I.get<ItemsListProvider>().validateItem(itemUuid, false);
      } else {
        GetIt.I.get<ItemsListProvider>().validateItem(itemUuid, true);
      }
    } else {
      GetIt.I.get<ItemsListProvider>().validateItem(itemUuid, true);
    }
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
