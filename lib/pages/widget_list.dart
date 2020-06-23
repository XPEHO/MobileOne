import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color WHITE = Colors.white;
const Color BLACK = Colors.black;
const Color GREY = Colors.grey;

class WidgetLists extends StatefulWidget {
  final String _listUuid;
  final String _itemPicture;
  final String _numberOfItemShared;

  WidgetLists(this._listUuid, this._itemPicture,
      this._numberOfItemShared);

  State<StatefulWidget> createState() {
    return WidgetListsState(_listUuid, _itemPicture, _numberOfItemShared);
  }
}

class WidgetListsState extends State<WidgetLists> {
  final String _listUuid;
  final String _itemPicture;
  final String _numberOfItemShared;
  WidgetListsState(this._listUuid, this._itemPicture, this._numberOfItemShared);

  String label = "";
  String count = "";

  Future<void> getListLabel() async {
    String labelValue;

    await Firestore.instance.collection("wishlists").document(_listUuid).get().then((value) => labelValue = value["label"]);

    setState(() {
      label = labelValue;
    });
  }

  Future<void> getListItemCount() async {
    String countValue;

    await Firestore.instance.collection("wishlists").document(_listUuid).get().then((value) => countValue = value["itemCounts"]);
    
    setState(() {
      count = countValue;
    });
  }

  @override
  void initState() {
    getListLabel();
    getListItemCount();
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
                child: Image.asset(_itemPicture),
              ),
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  count,
                  style: TextStyle(color: GREY, fontSize: 10.0),
                ),
              ),
              Text(
                _numberOfItemShared,
                style: TextStyle(color: GREY, fontSize: 10.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}