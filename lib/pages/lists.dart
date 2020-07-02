import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:MobileOne/pages/widget_list.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

const Color ORANGE = Colors.deepOrange;

class Lists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistsListProvider>(),
      child: Consumer<WishlistsListProvider>(
        builder: (context, wishlistsListProvider, child) {
          return FutureBuilder<DocumentSnapshot>(
            future: wishlistsListProvider.ownerLists,
            builder: (context, snapshot) {
              return content(snapshot.data);
            },
          );
        },
      ),
    );
  }

  Widget content(DocumentSnapshot snapshot) {
    final owner = snapshot?.data ?? {};
    final lists = owner["lists"] ?? [];
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 200.0, right: 300),
            child: Text(
              getString(context, 'my_lists'),
            ),
          ),
          Container(
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
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Text(
              getString(context, 'shared_with_me'),
            ),
          ),
        ],
      ),
    );
  }

  void openOpenedListPage(context, uuid) {
    Navigator.of(context)
        .pushNamed('/openedListPage', arguments: uuid.toString());
  }
}
