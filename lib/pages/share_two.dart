import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:MobileOne/pages/share_one.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class ShareTwo extends StatefulWidget {
  ShareStateTwoState createState() => ShareStateTwoState();
}

class ShareStateTwoState extends State<ShareTwo> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  final _myController = TextEditingController();
  var _listSelected;
  var userService = GetIt.I.get<UserService>();
  var shareProvider = GetIt.I.get<ShareProvider>();
  var _colorsApp = GetIt.I.get<ColorService>();
  var wishlistService = GetIt.I.get<WishlistService>();
  var whislistHeadProvider = GetIt.I.get<WishlistHeadProvider>();
  var test;

  List<String> listsFilter = [];
  List<String> listsUuidFilter = [];

  void initState() {
    _analytics.setCurrentPage("isOneShareTwoPage");
    super.initState();
    listsFilter = [];
    _myController.addListener(() {
      filterLists();
    });
  }

  String wish;
  filterLists() {
    List<String> _lists = [];

    for (int i = 0; i < test.length; i++) {
      wish = whislistHeadProvider.getWishlist(test[i]).label;
      _lists.add(wish);
    }

    if (_myController.text.isNotEmpty) {
      _lists.retainWhere((liste) {
        String searchTerm = _myController.text.toLowerCase();
        String listLabel = liste.toLowerCase();

        return listLabel.contains(searchTerm);
      });
      setState(() {
        listsFilter = _lists;
      });
    }
  }

  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("owners")
          .document(userService.user.uid)
          .get()
          .asStream(),
      builder: (context, snapshot) {
        var userWishlists = snapshot?.data?.data ?? {};
        var wishlists = userWishlists["lists"] ?? [];
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: WHITE,
            ),
          );
        else {
          return buildShareList(context, wishlists);
        }
      },
    );
  }

  Scaffold buildShareList(BuildContext context, wishlists) {
    test = wishlists;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: _colorsApp.colorTheme,
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
                        color: WHITE,
                      ),
                      onPressed: () {
                        openSharePage();
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
                        getString(context, "which_list"),
                        style: TextStyle(
                          fontSize: 20,
                          color: WHITE,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 100, right: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  child: Text(
                    getString(context, "step_one"),
                    style: TextStyle(
                      color: WHITE,
                      fontSize: 10,
                    ),
                  ),
                  radius: 12,
                  backgroundColor: _colorsApp.buttonColor,
                ),
                Expanded(
                  child: Divider(
                    color: WHITE,
                    height: 80,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                ),
                CircleAvatar(
                  child: Text(
                    getString(context, "step_two"),
                    style: TextStyle(
                      color: WHITE,
                      fontSize: 10,
                    ),
                  ),
                  radius: 12,
                  backgroundColor: _colorsApp.buttonColor,
                ),
              ],
            ),
          ),
          Container(
            color: WHITE,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: getString(context, "share_list"),
                  suffixIcon: Icon(
                    Icons.search,
                    color: BLACK,
                  ),
                ),
                controller: _myController,
                onChanged: (string) {
                  setState(
                    () {
                      listsFilter = test
                          .where((liste) => (liste
                              .toLowerCase()
                              .contains(string.toLowerCase())))
                          .toList();
                    },
                  );
                },
              ),
            ),
          ),
          (_myController.text.length >= 1 && listsFilter.isNotEmpty)
              ? Container(
                  height: 100,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wishlists.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return WidgetLists(
                          listUuid: whislistHeadProvider
                              .getWishlist(listsUuidFilter[index])
                              .uuid,
                        );
                      }))
              : Container(),
          Padding(
            padding: EdgeInsets.only(
              top: 50.0,
              right: 300,
            ),
            child: Text(
              getString(context, 'my_lists'),
              style: TextStyle(
                color: WHITE,
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
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: wishlists.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return GestureDetector(
                        onTap: () {
                          _listSelected = wishlists[index];
                          if (searchTermEmail != null) {
                            shareProvider.addSharedToDataBase(
                                searchTermEmail, _listSelected);
                            shareProvider.addGuestToDataBase(
                                searchTermEmail, _listSelected);
                            openSharePage();
                          } else {
                            shareProvider.addSharedToDataBase(
                                contactSelected.emails.elementAt(0).value,
                                _listSelected);
                            shareProvider.addGuestToDataBase(
                                contactSelected.emails.elementAt(0).value,
                                _listSelected);
                            openSharePage();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            child: WidgetLists(
                              listUuid: wishlists[index],
                            ),
                          ),
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

  void openSharePage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainPage"));
  }
}
