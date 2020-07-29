import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_popup.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WidgetItem extends StatefulWidget {
  final WishlistItem _itemlist;
  final String _listUuid;
  final String _itemUuid;
  WidgetItem(this._itemlist, this._listUuid, this._itemUuid);

  State<StatefulWidget> createState() {
    return WidgetItemState(_itemlist, _listUuid, _itemUuid);
  }
}

class WidgetItemState extends State<WidgetItem> {
  String _listUuid;
  String _itemUuid;
  final WishlistItem _itemlist;
  WidgetItemState(this._itemlist, this._listUuid, this._itemUuid);
  var _itemImage;

  @override
  void initState() {
    if (_itemlist.imageUrl != null) {
      _itemlist.imageUrl == "assets/images/canned-food.png"
          ? _itemImage = AssetImage(_itemlist.imageUrl)
          : _itemImage = NetworkImage(_itemlist.imageUrl);
    } else {
      _itemImage = AssetImage("assets/images/canned-food.png");
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    final completeName = _itemlist.label;
    if (_itemlist.isValidated) {
      return buildValidatedItem(completeName);
    } else {
      return buildItem(completeName);
    }
  }

  Builder buildValidatedItem(String completeName) {
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
                Text("${_itemlist.quantity.toString()} ${getUnitText()}"),
              ],
            ),
            leading: SizedBox(
              width: 72,
              height: 72,
              child: Row(children: <Widget>[
                Flexible(
                  flex: 1,
                  child: IconButton(
                    padding: EdgeInsets.only(right: 12.0),
                    icon: Icon(
                      Icons.check_circle,
                      color: GREEN,
                    ),
                    onPressed: () => GetIt.I
                        .get<ItemsListProvider>()
                        .validateItem(_itemlist.uuid, false),
                  ),
                ),
                Flexible(flex: 1, child: Image(image: _itemImage))
              ]),
            ),
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

  Builder buildItem(String completeName) {
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
                Text("${_itemlist.quantity.toString()} ${getUnitText()}"),
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
    switch (_itemlist.unit) {
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
