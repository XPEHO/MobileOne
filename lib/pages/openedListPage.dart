import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/widgets/widget_item.dart';
import 'package:MobileOne/widgets/widget_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../localization/localization.dart';

const Color GREEN = Colors.green;
const Color GREY = Colors.grey;
const Color GREY600 = Colors.grey;
const Color RED = Colors.red;
const Color WHITE = Colors.white;
const Color TRANSPARENT = Colors.transparent;

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
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              new ListView.builder(
                  padding: EdgeInsets.only(top: 30),
                  itemCount: wishlist.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Dismissible(
                        confirmDismiss: (DismissDirection direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(getString(
                                    context, 'confirm_item_deletion')),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                          getString(context, 'delete_item'))),
                                  FlatButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(
                                        getString(context, 'cancel_deletion')),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        background: Container(color: Colors.red),
                        key: UniqueKey(),
                        child: WidgetItem(wishlist.values.toList()[index],
                            listUuid, wishlist.keys.toList()[index]),
                        onDismissed: (direction) {
                          deleteItemFromList(wishlist.keys.toList()[index]);
                        });
                  }),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          openListsPage();
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: PopupMenuButton(
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
                                  GetIt.I
                                      .get<WishlistsListProvider>()
                                      .deleteWishlist(listUuid,
                                          GetIt.I.get<UserService>().user.uid);
                                }
                              });
                              break;
                            case 2:
                              askPermissions(uuid);
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => EditItemPopup(
                            getString(context, 'popup_add'), listUuid, null));
                  },
                  child: Icon(Icons.add),
                  backgroundColor: GREEN,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteItemFromList(String uuid) {
    GetIt.I.get<ItemsListProvider>().deleteItemInList(uuid);
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
    Navigator.of(context).pushNamed('/shareOne', arguments: uuid);
  }
}
