import 'package:MobileOne/data/categories.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/share_service.dart';
import 'package:MobileOne/services/tutorial_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_custom_drawer.dart';
import 'package:MobileOne/widgets/widget_empty_list.dart';
import 'package:MobileOne/widgets/widget_emty_template.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Lists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> with TickerProviderStateMixin {
  var lists = [];
  var guestList = [];
  var _userService = GetIt.I.get<UserService>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  var _wishlistProvider = GetIt.I.get<WishlistsListProvider>();
  final _tutorialService = GetIt.I.get<TutorialService>();
  var share = GetIt.I.get<ShareService>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  TabController _tabController;
  int _tabIndex = 0;

  List<TargetFocus> targets = List();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnListPage");
    super.initState();
  }

  void _onRefresh() async {
    _wishlistProvider.flushWishlists(_userService.user.email);
    _refreshController.refreshCompleted();
  }

  void initTargets() {
    targets.add(
      _tutorialService.createTarget(
        identifier: "Add a list",
        position: TargetPosition(
            Size(40, 40),
            Offset(
              (MediaQuery.of(context).size.width / 2) - 20,
              MediaQuery.of(context).size.height - 80,
            )),
        title: getString(context, "tutorial_add_list_title"),
        text: getString(context, "tutorial_add_list_text"),
        positionBottom: 200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initTargets();
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistsListProvider>(),
      child: Consumer<WishlistsListProvider>(
          builder: (context, wishlistsListProvider, child) {
        List<Widget> _tabs = getAllTabs(wishlistsListProvider);
        List<Widget> _tabsContent = setAllTabsContent(wishlistsListProvider);
        _tabController = TabController(
            initialIndex: _tabIndex, length: _tabs.length, vsync: this);
        return Scaffold(
          appBar: AppBar(
            backgroundColor: _colorsApp.colorTheme,
          ),
          drawer: CustomDrawer(
            context: context,
            targets: targets,
          ),
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
                    flex: 2,
                    child: Container(
                      child: logo(),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: TabBar(
                          onTap: (index) => {
                            _tabIndex = index,
                          },
                          controller: _tabController,
                          tabs: _tabs,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: TabBarView(
                      controller: _tabController,
                      children: _tabsContent,
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

  List<Widget> getAllTabs(WishlistsListProvider wishlistsListProvider) {
    List<Widget> tabs = [];
    List<Categories> categories = wishlistsListProvider.getCategories(context);
    Map<String, List<Wishlist>> ownerLists = wishlistsListProvider.ownerLists;

    tabs.add(
      Container(
        height: 36,
        child: FittedBox(
          child: Text(
            getString(context, 'null_category'),
            style: TextStyle(color: WHITE),
          ),
        ),
      ),
    );

    if (ownerLists.length > 0) {
      categories.forEach(
        (element) {
          if (ownerLists.containsKey(element.id)) {
            tabs.add(
              Container(
                height: 36,
                child: FittedBox(
                  child: Text(
                    element.label,
                    style: TextStyle(color: WHITE),
                  ),
                ),
              ),
            );
          }
        },
      );
    }

    tabs.add(
      Container(
        height: 36,
        child: FittedBox(
          child: Text(
            getString(context, 'shared_with_me'),
            style: TextStyle(color: WHITE),
          ),
        ),
      ),
    );

    return tabs;
  }

  List<Widget> setAllTabsContent(WishlistsListProvider wishlistsListProvider) {
    List<Widget> tabsContent = [];
    Map<String, List<Wishlist>> ownerLists = wishlistsListProvider.ownerLists;

    if (ownerLists.length == 0) {
      tabsContent.add(
        Container(
          width: double.infinity,
          height: 100,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
                onTap: () {
                  createList();
                },
                child: buildEmptyTemplate()),
          ),
        ),
      );
    } else {
      List<Categories> categories =
          wishlistsListProvider.getCategories(context);
      categories.forEach((element) {
        if (element.id != null) {
          if (ownerLists.containsKey(element.id)) {
            tabsContent.add(buildWishlists(ownerLists[element.id]));
          }
        } else {
          tabsContent.add(buildWishlists(ownerLists["no_category"]));
        }
      });
    }

    tabsContent.add(buildSharedWishlists(wishlistsListProvider));

    return tabsContent;
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

  buildWishlists(List<Wishlist> wishlists) {
    return Builder(
      builder: (context) {
        if (wishlists == null || wishlists.isEmpty)
          return Center(
            child: Text(
              getString(context, "empty_category"),
              style: TextStyle(fontSize: 24, color: WHITE),
            ),
          );
        else {
          return contentList(wishlists);
        }
      },
    );
  }

  Widget contentList(List<Wishlist> wishlists) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: wishlists.length,
        itemBuilder: (BuildContext ctxt, index) {
          return GestureDetector(
              onTap: () {
                openOpenedListPage(wishlists[index].uuid, false);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: WidgetLists(
                    listUuid: wishlists[index].uuid, isGuest: false),
              ));
        },
      ),
    );
  }

  buildSharedWishlists(WishlistsListProvider provider) {
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: guestList.length,
          itemBuilder: (BuildContext ctxt, index) {
            return Container(
              child: GestureDetector(
                  onTap: () {
                    openOpenedListPage(guestList[index], true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child:
                        WidgetLists(listUuid: guestList[index], isGuest: true),
                  )),
            );
          },
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
