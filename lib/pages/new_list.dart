import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_empty_list.dart';
import 'package:MobileOne/widgets/widget_emty_template.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class NewLists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return NewListsState();
  }
}

class NewListsState extends State<NewLists> {
  var lists = [];
  var guestList = [];
  var _userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnListPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistsListProvider>(),
      child: Consumer<WishlistsListProvider>(
          builder: (context, wishlistsListProvider, child) {
        return Scaffold(
          backgroundColor: _colorsApp.colorTheme,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/square-logo.png',
                        width: 100, height: 100),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16.0, bottom: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              getString(context, 'all_my_lists'),
                              style: TextStyle(color: WHITE),
                            ),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.17,
                          child: buildFuturBuilderList(wishlistsListProvider),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 16.0, bottom: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              getString(context, 'shared_with_me'),
                              style: TextStyle(color: WHITE),
                            ),
                          ),
                        ),
                        buildFuturBuilderGuest(wishlistsListProvider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Container buildEmptyTemplate() {
    return Container(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              openCreateListPage();
            },
            child: EmptyLists(
                icon: Icons.add_shopping_cart,
                text: getString(context, "create_list")),
          ),
          EmptyTemplate(),
          EmptyTemplate(),
          EmptyTemplate(),
          EmptyTemplate(),
        ],
      ),
    );
  }

  Container emptyShare() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        children: <Widget>[
          Icon(Icons.share, size: 90, color: _colorsApp.greyColor),
          Text(
            getString(context, "no_sharing"),
            style: TextStyle(fontSize: 25, color: _colorsApp.greyColor),
          ),
        ],
      ),
    );
  }

  buildFuturBuilderList(WishlistsListProvider provider) {
    return FutureBuilder<List>(
      future: provider.ownerLists,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
        else {
          return contentList(snapshot.data);
        }
      },
    );
  }

  Widget contentList(List lists) {
    if (lists.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
            onTap: () {
              openCreateListPage();
            },
            child: buildEmptyTemplate()),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: lists.length,
          itemBuilder: (BuildContext ctxt, index) {
            return GestureDetector(
                onTap: () {
                  openOpenedListPage(lists[index], false);
                },
                child: Container(
                  height: 100,
                  child: WidgetLists(
                      lists[index], getString(context, "shared_count")),
                ));
          },
        ),
      );
    }
  }

  buildFuturBuilderGuest(WishlistsListProvider provider) {
    return FutureBuilder<List>(
      future: provider.guestLists(_userService.user.email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: CircularProgressIndicator(),
          );
        else {
          return contentGuest(snapshot.data);
        }
      },
    );
  }

  Widget contentGuest(List guestList) {
    if (guestList.isEmpty) {
      return emptyShare();
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.17,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: guestList.length,
              itemBuilder: (BuildContext ctxt, index) {
                return GestureDetector(
                    onTap: () {
                      openOpenedListPage(guestList[index], true);
                    },
                    child: WidgetLists(
                        guestList[index], getString(context, "shared_count")));
              },
            ),
          ),
        ),
      );
    }
  }

  void openCreateListPage() {
    Navigator.of(context).pushNamed('/createList');
  }

  void openOpenedListPage(String uuid, bool isGuest) {
    Navigator.of(context).pushNamed('/openedListPage',
        arguments: OpenedListArguments(listUuid: uuid, isGuest: isGuest));
  }
}
