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

  var completeName;

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
    completeName = _itemslist["label"];
    return Row(
      children: [
        new Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: new Center(
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.02,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Image(
                      image: _itemImage,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.1,
                  left: MediaQuery.of(context).size.width * 0.25,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      completeName.substring(0, completeName.indexOf('-')),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.15,
                  left: MediaQuery.of(context).size.width * 0.26,
                  child: Text(
                    completeName.substring(completeName.indexOf('-') + 1),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.21,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: Text(
                    _itemslist["quantity"].toString(),
                    style: TextStyle(
                      color: GREY,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.width * 0.21,
                  left: MediaQuery.of(context).size.width * 0.5,
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
