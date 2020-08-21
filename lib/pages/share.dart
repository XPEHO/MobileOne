import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/widgets/widget_empty_list.dart';
import 'package:MobileOne/widgets/widget_share_lists.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          return FutureBuilder<DocumentSnapshot>(
              future: shareProvider.ownerLists,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: WHITE,
                    ),
                  );
                else {
                  return content(snapshot.data);
                }
              });
        },
      ),
    );
  }

  Widget content(DocumentSnapshot snapshot) {
    var userWishlists = snapshot?.data ?? {};
    var wishlist = userWishlists["lists"] ?? [];

    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
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
                              color: WHITE,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (wishlist.length != 0)
                  ? buildLIstView(wishlist)
                  : buildEmptyShare()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyShare() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                openCreateListPage();
              },
              child: EmptyLists(
                icon: Icons.add_shopping_cart,
                text: getString(context, "create_list"),
                color: _colorsApp.microColor,
                textAndIconColor: WHITE,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildLIstView(wishlist) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.76,
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
    PermissionStatus permissionStatus = await _getContactPermission();

    if (permissionStatus != PermissionStatus.granted) {
      openMainPage();
    } else {
      openShareOnePage();
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

  void openShareOnePage() {
    Navigator.pushNamed(context, '/shareOne',
        arguments: ShareArguments(previousList: previousList));
  }

  void openMainPage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainPage"));
  }

  void openCreateListPage() {
    Navigator.of(context).pushNamed('/createList');
  }
}
