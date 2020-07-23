import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
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
      body: SafeArea(
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: wishlist.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return GestureDetector(
                          onTap: () {
                            previousList = wishlist[index];
                            askPermissions();
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
    Navigator.pushNamed(context, '/shareOne', arguments: previousList);
  }

  void openMainPage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainpage"));
  }
}
