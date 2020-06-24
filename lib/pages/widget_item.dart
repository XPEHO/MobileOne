import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/wisget_popup.dart';
import 'package:flutter/material.dart';

const Color GREEN = Colors.green;
const Color GREY = Colors.grey;
const Color GREY600 = Colors.grey;
const Color RED = Colors.red;
const Color WHITE = Colors.white;
const Color TRANSPARENT = Colors.transparent;
bool isUpdate=false;

class WidgetItem extends StatefulWidget {
  final String _itemName;
  final String _itemCount;
  final String _itemType;
<<<<<<< HEAD
   final String _listUuid;
      final String _itemUuid;
  WidgetItem(this._itemName, this._itemCount, this._itemType,this._listUuid,this._itemUuid);
=======
  final String _listUuid;
  WidgetItem(this._itemName, this._itemCount, this._itemType,this._listUuid);
>>>>>>> 66d1c8cfd21521bdf0d004631d11cfa50a2c0f8e

  State<StatefulWidget> createState() {
    return WidgetItemState(_itemName, _itemCount, _itemType,_listUuid,_itemUuid);
  }
}

class WidgetItemState extends State<WidgetItem> {
  String _listUuid;
  String _itemName;
  String _itemCount;
  String _itemType;
     final String _itemUuid;
  WidgetItemState(this._itemName, this._itemCount, this._itemType,this._listUuid,this._itemUuid);


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
                    _itemName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 100,
                  child: Text(
                    _itemCount,
                    style: TextStyle(
                      color: GREY,
                    ),
                  ),
                ),
                Positioned(
                  left: 150,
                  top: 60,
                  child: Text(
                    _itemType,
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
                         
                              WidgetPopup(getString(context, 'popup_update'),  _listUuid,_itemUuid));
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
