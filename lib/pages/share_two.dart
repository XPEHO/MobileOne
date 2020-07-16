import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/services/user_service.dart';
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
  final _myController = TextEditingController();
  var _listSelected;
  var userService = GetIt.I.get<UserService>();
  var shareProvider = GetIt.I.get<ShareProvider>();
  void initState() {
    super.initState();
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
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
                  backgroundColor: GREEN,
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black,
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
                  backgroundColor: BLUE,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 50,
            child: TextField(
              controller: _myController,
              decoration: InputDecoration(
                hintText: getString(context, "share_email"),
                labelText: getString(context, 'search'),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: BLUE,
                  ),
                ),
                suffixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 50.0,
              right: 300,
            ),
            child: Text(
              getString(context, 'my_lists'),
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
                        child: WidgetLists(
                          wishlists[index],
                          getString(context, "shared_count"),
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
    Navigator.popUntil(context, ModalRoute.withName("/mainpage"));
  }
}
