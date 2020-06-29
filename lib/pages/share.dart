import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/widgets/widget_share_lists.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class Share extends StatefulWidget {
  ShareState createState() => ShareState();
}

class ShareState extends State<Share> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<ShareProvider>(),
      child: Consumer<ShareProvider>(
        builder: (context, shareProvider, child) {
          return FutureBuilder<DocumentSnapshot>(
            future: shareProvider.ownerLists,
            builder: (context, snapshot) {
              return content(snapshot.data);
            },
          );
        },
      ),
    );
  }

  Widget content(DocumentSnapshot snapshot) {
    var userWishlists = snapshot?.data ?? {};
    var wishlist = userWishlists["lists"] ?? [];
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 30,
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                      ),
                      onPressed: () {
                        openMainPage();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 7,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Text(
                        getString(context, "my_shares"),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 200,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: wishlist.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return GestureDetector(
                        onTap: () {
                          openOpenedListPage(
                            context,
                            wishlist[index],
                          );
                        },
                        child: WidgetShareListWithSomeone(
                          wishlist[index],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openMainPage() {
    Navigator.of(context).pushNamed('/mainpage');
  }

  void openOpenedListPage(context, uuid) {
    Navigator.of(context)
        .pushNamed('/openedListPage', arguments: uuid.toString());
  }
}
