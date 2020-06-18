import 'package:flutter/material.dart';

const Color WHITE = Colors.white;
const Color BLACK = Colors.black;
const Color GREY = Colors.grey;

class WidgetLists extends StatelessWidget {
  final String _itemName;
  final String _itemPicture;
  final String _numberOfItem;
  final String _numberOfItemShared;

  WidgetLists(this._itemName, this._itemPicture, this._numberOfItem,
      this._numberOfItemShared);

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
                  _itemName,
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
                  _numberOfItem,
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
