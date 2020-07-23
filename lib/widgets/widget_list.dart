import 'package:MobileOne/localization/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';

class WidgetLists extends StatefulWidget {
  final String _listUuid;
  final String _numberOfItemShared;

  WidgetLists(this._listUuid, this._numberOfItemShared);

  State<StatefulWidget> createState() {
    return WidgetListsState(_listUuid, _numberOfItemShared);
  }
}

class WidgetListsState extends State<WidgetLists> {
  final String _listUuid;
  final String _numberOfItemShared;
  WidgetListsState(this._listUuid, this._numberOfItemShared);
  String label = "";
  String count = "";

  Future<void> getListDetails() async {
    String labelValue;
    String countValue;

    await Firestore.instance
        .collection("wishlists")
        .document(_listUuid)
        .get()
        .then((value) {
      labelValue = value["label"];
      countValue = value["itemCounts"] + " " + getString(context, 'articles');
    });

    setState(() {
      label = labelValue;
      count = countValue;
    });
  }

  @override
  void initState() {
    getListDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.23,
      child: Card(
        elevation: 3,
        color: WHITE,
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: BLACK, fontSize: 12.0),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.23 / 2,
                child: Image.asset("assets/images/basket_my_lists.png"),
              ),
              Text(
                count,
                style: TextStyle(color: GREY, fontSize: 8.0),
              ),
              Text(
                _numberOfItemShared,
                style: TextStyle(color: GREY, fontSize: 8.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
