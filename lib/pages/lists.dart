import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:MobileOne/widgets/widget_list.dart';

class Lists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> {
  var _userService = GetIt.I.get<UserService>();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistsListProvider>(),
      child: Consumer<WishlistsListProvider>(
        builder: (context, wishlistsListProvider, child) {
          return Scaffold(
            body: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 200.0, right: 300),
                  child: Text(
                    getString(context, 'my_lists'),
                  ),
                ),
                buildFuturBuilderList(wishlistsListProvider),
                Padding(
                  padding: EdgeInsets.only(top: 50.0),
                  child: Text(
                    getString(context, 'shared_with_me'),
                  ),
                ),
                buildFuturBuilderGuest(wishlistsListProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  buildFuturBuilderList(WishlistsListProvider provider) {
    return FutureBuilder<DocumentSnapshot>(
      future: provider.ownerLists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator(
            strokeWidth: 1,
          );
        else {
          return contentList(snapshot.data);
        }
      },
    );
  }

  Widget contentList(DocumentSnapshot snapshot) {
    final owner = snapshot?.data ?? {};
    final lists = owner["lists"] ?? [];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lists.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return GestureDetector(
              onTap: () {
                openOpenedListPage(context, lists[index]);
              },
              child: WidgetLists(
                  lists[index], getString(context, "shared_count")));
        },
      ),
    );
  }

  buildFuturBuilderGuest(WishlistsListProvider provider) {
    return FutureBuilder<DocumentSnapshot>(
      future: provider.guestLists(_userService.user.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return CircularProgressIndicator(
            strokeWidth: 1,
          );
        else {
          return contentGuest(snapshot.data);
        }
      },
    );
  }

  Widget contentGuest(DocumentSnapshot snapshot) {
    final guest = snapshot?.data ?? {};
    final guestList = guest["lists"] ?? [];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: guestList.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return GestureDetector(
              onTap: () {
                openOpenedListPage(context, guestList[index]);
              },
              child: WidgetLists(
                  guestList[index], getString(context, "shared_count")));
        },
      ),
    );
  }

  void openOpenedListPage(context, uuid) {
    GetIt.I.get<ItemsListProvider>().listUuid = uuid;
    Navigator.of(context).pushNamed('/openedListPage');
  }
}
