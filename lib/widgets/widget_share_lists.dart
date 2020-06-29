import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/utility/database.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';

class WidgetShareListWithSomeone extends StatefulWidget {
  final String _listUuid;
  WidgetShareListWithSomeone(this._listUuid);
  State<StatefulWidget> createState() {
    return WidgetShareListWithSomeoneState(_listUuid);
  }
}

class WidgetShareListWithSomeoneState
    extends State<WidgetShareListWithSomeone> {
  final String _listUuid;
  WidgetShareListWithSomeoneState(this._listUuid);
  var userService = GetIt.I.get<UserService>();
  var numberOfItemShared = "0";
  String _label = "";
  String _count = "";

  Future<void> getListDetails() async {
    String labelValue;
    String countValue;

    await databaseReference
        .collection("wishlists")
        .document(_listUuid)
        .get()
        .then((value) {
      labelValue = value["label"];
      countValue = value["itemCounts"] + " " + getString(context, 'articles');
    });

    setState(() {
      _label = labelValue;
      _count = countValue;
    });
  }

  @override
  void initState() {
    super.initState();
    getListDetails();
  }

  @override
  Widget build(BuildContext context) {
    var sharedCount = getString(context, "shared_count");
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("shared")
          .document(userService.user.uid)
          .get()
          .asStream(),
      builder: (context, snapshot) {
        var _emails = snapshot?.data?.data ?? {};

        return Row(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 10,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.23,
                    child: Card(
                      elevation: 3,
                      color: WHITE,
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                              ),
                              child: Text(
                                _label,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: BLACK,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 0.23 / 2,
                              child: Image.asset(
                                  "assets/images/basket_my_lists.png"),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 20,
                              ),
                              child: Text(
                                _count,
                                style: TextStyle(
                                  color: GREY,
                                  fontSize: 10.0,
                                ),
                              ),
                            ),
                            Text(
                              "$numberOfItemShared $sharedCount",
                              style: TextStyle(
                                color: GREY,
                                fontSize: 10.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 140,
                    top: 15,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width - 160,
                    height: 80,
                    child: Stack(
                      children: <Widget>[
                        Text(
                          getString(context, "shared_with"),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            top: 20,
                          ),
                          child: Container(
                            width: 250,
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: _emails[_listUuid] != null
                                  ? _emails[_listUuid].length
                                  : 0,
                              itemBuilder: (BuildContext ctxt, int index) {
                                numberOfItemShared =
                                    _emails[_listUuid].length.toString();
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              200,
                                          child: Text(
                                            _emails[_listUuid][index],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/delete.png',
                                          height: 30,
                                          width: 30,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
