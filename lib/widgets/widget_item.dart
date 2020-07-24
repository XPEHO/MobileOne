import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/widgets/widget_popup.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';

class WidgetItem extends StatefulWidget {
  final Map<String, dynamic> _itemslist;
  final String _listUuid;
  final String _itemUuid;
  WidgetItem(this._itemslist, this._listUuid, this._itemUuid);

  State<StatefulWidget> createState() {
    return WidgetItemState(_itemslist, _listUuid, _itemUuid);
  }
}

class WidgetItemState extends State<WidgetItem> {
  String _listUuid;
  String _itemUuid;
  final Map<String, dynamic> _itemslist;
  WidgetItemState(this._itemslist, this._listUuid, this._itemUuid);
  var _itemImage;

  @override
  void initState() {
    if (_itemslist["image"] != null) {
      _itemslist["image"] == "assets/images/canned-food.png"
          ? _itemImage = AssetImage(_itemslist["image"])
          : _itemImage = NetworkImage(_itemslist["image"]);
    } else {
      _itemImage = AssetImage("assets/images/canned-food.png");
    }
    super.initState();
  }

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
                    height: 48,
                    width: 48,
                    child: Image(
                      image: _itemImage,
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
                    getUnitText(),
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
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => EditItemPopup(
                              getString(context, 'popup_update'),
                              _listUuid,
                              _itemUuid));
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

  String getUnitText() {
    switch (_itemslist["unit"]) {
      case 1:
        return getString(context, 'item_unit');
        break;
      case 2:
        return getString(context, 'item_liters');
        break;
      case 3:
        return getString(context, 'item_grams');
        break;
      case 4:
        return getString(context, 'item_kilos');
        break;
      default:
        return getString(context, 'item_unit');
        break;
    }
  }
}
