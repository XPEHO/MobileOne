import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/widget_popup.dart';
import 'package:flutter/material.dart';

const Color GREEN = Colors.green;
const Color GREY = Colors.grey;
const Color GREY600 = Colors.grey;
const Color RED = Colors.red;
const Color WHITE = Colors.white;
const Color TRANSPARENT = Colors.transparent;
bool isUpdate=false;

class WidgetItem extends StatefulWidget {
  final Map<String, dynamic> _itemslist;
  final String _listUuid;
  WidgetItem(this._itemslist ,this._listUuid);

  State<StatefulWidget> createState() {
    return WidgetItemState(_itemslist, _listUuid);
  }
}

class WidgetItemState extends State<WidgetItem> {
  String _listUuid;
  final Map<String, dynamic> _itemslist;
  WidgetItemState(this._itemslist ,this._listUuid);

  Widget build(BuildContext context) {
    return Row(
      children: [
        new Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: new Center(
            child: Stack(
              children: [
                Positioned(
                  top: 25,
                  left: 10,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Image(
                      image: AssetImage("assets/images/bottle_of_water.png"),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 100,
                  child: Text(
                    _itemslist["label"],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 100,
                  child: Text(
                    _itemslist["quantity"].toString(),
                    style: TextStyle(
                      color: GREY,
                    ),
                  ),
                ),
                Positioned(
                  left: 150,
                  top: 60,
                  child: Text(
                    _itemslist["unit"],
                    style: TextStyle(
                      color: GREY,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                       isUpdate=true;
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              WidgetPopup(getString(context, 'popup_update'), _listUuid));
                    },
                    icon: Icon(Icons.edit),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}