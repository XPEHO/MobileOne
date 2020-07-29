import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/widgets/widget_popup.dart';
import 'package:flutter/material.dart';

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
    final completeName = _itemslist["label"];
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(getProductName(completeName)),
                Text(getProductBrand(completeName)),
              ],
            ),
            subtitle: Row(
              children: <Widget>[
                Text("${_itemslist["quantity"].toString()} ${getUnitText()}"),
              ],
            ),
            leading: Image(image: _itemImage),
            trailing: IconButton(
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
          ),
        );
      },
    );
  }

  getProductBrand(String completeName) {
    if (completeName.contains('-')) {
      return completeName.substring(completeName.indexOf('-') + 1);
    }

    return "";
  }

  getProductName(String completeName) {
    if (completeName.contains('-')) {
      return completeName.substring(0, completeName.indexOf('-'));
    }
    return completeName;
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
