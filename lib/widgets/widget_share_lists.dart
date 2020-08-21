import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';

import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/utility/database.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

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
  var shareProvider = GetIt.I.get<ShareProvider>();

  String label = "";
  String count = "";
  var numberOfItemShared = "0";
  Future<void> getListDetails() async {
    String labelValue;
    String countValue;

    await databaseReference
        .collection("wishlists")
        .document(_listUuid)
        .get()
        .then((value) {
      labelValue = value["label"];
      countValue = value["itemCounts"] + " " + getString(context, 'items');
    });

    setState(() {
      label = labelValue;
      count = countValue;
    });
  }

  @override
  void initState() {
    super.initState();
    getListDetails();
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<ShareProvider>(),
      child: Consumer<ShareProvider>(
        builder: (context, shareProvider, child) {
          return FutureBuilder<DocumentSnapshot>(
            future: shareProvider.shareLists,
            builder: (context, snapshot) {
              return content(snapshot.data);
            },
          );
        },
      ),
    );
  }

  Widget content(DocumentSnapshot snapshot) {
    var _emails = snapshot?.data ?? {};

    return Row(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: 10,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.23,
                height: MediaQuery.of(context).size.width * 0.3,
                child: WidgetLists(
                    listUuid: _listUuid,
                    numberOfItemShared: numberOfItemShared),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 120,
                top: 15,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width * 0.6,
                child: Stack(
                  children: <Widget>[
                    Text(
                      getString(context, "shared_with"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: WHITE,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 10,
                        top: 20,
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _emails[_listUuid] != null
                            ? _emails[_listUuid].length
                            : 0,
                        itemBuilder: (BuildContext ctxt, int index) {
                          numberOfItemShared =
                              _emails[_listUuid].length.toString();

                          var emailSelected = _emails[_listUuid][index];
                          return Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  _emails[_listUuid][index],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: WHITE,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  shareProvider.deleteShared(
                                      _listUuid, emailSelected);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/images/eraser.png',
                                    height: 15,
                                    width: 15,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
  }
}
