import 'package:MobileOne/localization/localization.dart';

import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/share_service.dart';

import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_empty_list.dart';
import 'package:MobileOne/widgets/widget_emty_template.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Lists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> {
  var lists = [];
  var guestList = [];
  var _userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  var _wishlistProvider = GetIt.I.get<WishlistsListProvider>();
  var share = GetIt.I.get<ShareService>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _analytics.setCurrentPage("isOnListPage");
    super.initState();
  }

  void _onRefresh() async {
    _wishlistProvider.flushWishlists();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistsListProvider>(),
      child: Consumer<WishlistsListProvider>(
          builder: (context, wishlistsListProvider, child) {
        return Scaffold(
          backgroundColor: _colorsApp.colorTheme,
          body: SmartRefresher(
            header: WaterDropHeader(
              refresh: Text(
                getString(context, "refresh"),
                style: TextStyle(color: WHITE),
              ),
              complete: Text(
                getString(context, "refresh_complete"),
                style: TextStyle(color: WHITE),
              ),
              failed: Text(
                getString(context, "refresh_failed"),
                style: TextStyle(color: WHITE),
              ),
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: logo(),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: allMyLists(context, wishlistsListProvider),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: allSharedLists(context, wishlistsListProvider),
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

  Padding allSharedLists(
      BuildContext context, WishlistsListProvider wishlistsListProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getString(context, 'shared_with_me'),
                  style: TextStyle(color: WHITE),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              child: buildFuturBuilderGuest(wishlistsListProvider),
            ),
          ),
        ],
      ),
    );
  }

  Padding allMyLists(
      BuildContext context, WishlistsListProvider wishlistsListProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  getString(context, 'all_my_lists'),
                  style: TextStyle(color: WHITE),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              child: buildFuturBuilderList(wishlistsListProvider),
            ),
          ),
        ],
      ),
    );
  }

  Padding logo() {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 16.0),
      child:
          Image.asset('assets/images/square-logo.png', width: 80, height: 80),
    );
  }

  Container buildEmptyTemplate() {
    return Container(
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              createList();
            },
            child: EmptyLists(
              icon: Icons.add_shopping_cart,
              text: getString(context, "create_list"),
              textAndIconColor: GREY,
            ),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.share, size: 50, color: _colorsApp.greyColor),
          Text(
            getString(context, "no_sharing"),
            style: TextStyle(fontSize: 20, color: _colorsApp.greyColor),
          ),
        ],
      ),
    );
  }

  buildFuturBuilderList(WishlistsListProvider provider) {
    return Builder(
      builder: (context) {
        final ownerLists = provider.ownerLists;
        if (ownerLists == null)
          return Center(
            child: CircularProgressIndicator(),
          );
        else {
          return contentList(ownerLists);
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
              createList();
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
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: WidgetLists(
                      listUuid: lists[index],
                    ),
                  ),
                ));
          },
        ),
      );
    }
  }

  buildFuturBuilderGuest(WishlistsListProvider provider) {
    return Builder(
      builder: (context) {
        final guestLists = provider.guestLists(_userService.user.email);
        if (guestLists == null)
          return Center(
            child: CircularProgressIndicator(),
          );
        else {
          return contentGuest(guestLists);
        }
      },
    );
  }

  Widget contentGuest(List guestList) {
    if (guestList.isEmpty) {
      return emptyShare();
    } else {
      return Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: guestList.length,
              itemBuilder: (BuildContext ctxt, index) {
                return GestureDetector(
                    onTap: () {
                      openOpenedListPage(guestList[index], true);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: WidgetLists(
                        listUuid: guestList[index],
                      ),
                    ));
              },
            ),
          ),
        ),
      );
    }
  }

  void createList() async {
    await _wishlistProvider.addWishlist(context);
  }

  void openOpenedListPage(String uuid, bool isGuest) {
    Navigator.of(context).pushNamed('/openedListPage',
        arguments: OpenedListArguments(listUuid: uuid, isGuest: isGuest));
  }
}
