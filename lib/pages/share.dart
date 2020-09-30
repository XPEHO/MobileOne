import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/permissions/permissions.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/widgets/widget_empty_list.dart';
import 'package:MobileOne/widgets/widget_share_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:MobileOne/utility/colors.dart';

class Share extends StatefulWidget {
  ShareState createState() => ShareState();
}

class ShareState extends State<Share> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnSharePage");
    super.initState();
  }

  var previousList;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<ShareProvider>(),
      child: Consumer<ShareProvider>(
        builder: (context, shareProvider, child) {
          return Builder(
            builder: (context) {
              final ownerLists = shareProvider.ownerLists;
              if (ownerLists == null)
                return Center(
                  child: CircularProgressIndicator(),
                );
              else {
                return content(ownerLists);
              }
            },
          );
        },
      ),
    );
  }

  Widget content(List wishlist) {
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body:
          (wishlist.length != 0) ? buildLIstView(wishlist) : buildEmptyShare(),
    );
  }

  Widget buildEmptyShare() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Text(
                  getString(context, "need_list_to_share"),
                  style: TextStyle(fontSize: 15, color: WHITE),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.17,
                child: GestureDetector(
                  onTap: () {
                    createList();
                  },
                  child: EmptyLists(
                    icon: Icons.add_shopping_cart,
                    text: getString(context, "create_list"),
                    color: _colorsApp.buttonColor,
                    textAndIconColor: WHITE,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildLIstView(wishlist) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: double.infinity,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          bottom: kFloatingActionButtonMargin + 24,
        ),
        scrollDirection: Axis.vertical,
        itemCount: wishlist.length,
        itemBuilder: (BuildContext ctxt, int index) {
          return GestureDetector(
            onTap: () {
              previousList = wishlist[index];
              _analytics.sendAnalyticsEvent("share_list_from_share_page");
              askPermissions();
            },
            child: WidgetShareListWithSomeone(
              wishlist[index],
            ),
          );
        },
      ),
    );
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await getContactPermission();

    if (permissionStatus != PermissionStatus.granted) {
      openMainPage();
    } else {
      openShareOnePage();
    }
  }

  void openShareOnePage() {
    Navigator.pushNamed(context, '/shareOne',
        arguments: ShareArguments(previousList: previousList));
  }

  void openMainPage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainPage"));
  }

  void createList() async {
    await GetIt.I.get<WishlistsListProvider>().addWishlist(context);
  }
}
