import 'package:MobileOne/data/wishlist_item.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
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
  var _colorsApp = GetIt.I.get<ColorService>();

  @override
  void initState() {
    if (_itemlist.imageUrl != null) {
      _itemlist.imageUrl == "assets/images/canned-food.png"
          ? _itemImage = _itemImage = Icon(
              Icons.photo_outlined,
              size: 48,
              color: Colors.grey[400],
            )
          : _itemImage = Image(
              image: NetworkImage(_itemlist.imageUrl),
              width: 48,
              height: 48,
            );
    } else {
      _itemImage = _itemImage = Icon(
        Icons.photo_outlined,
        size: 48,
        color: Colors.grey[400],
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final completeName = _itemlist.label ?? "";
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
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: InkWell(
            onTap: () {
              openItemPage(
                _listUuid,
                _itemUuid,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: _colorsApp.greyColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                      Text(
                          "x${_itemlist.quantity.toString()} ${getUnitText()}"),
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
                            onPressed: () {
                              GetIt.I.get<ItemsListProvider>().validateItem(
                                    listUuid: _listUuid,
                                    itemUuid: _itemlist.uuid,
                                    isValidated: false,
                                  );
                            }),
                      ),
                      Flexible(flex: 1, child: _itemImage)
                    ]),
                  ),
                  trailing: Icon(
                    Icons.navigate_next,
                    color: BLACK,
                  ),
                ),
              ),
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
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
          child: InkWell(
            onTap: () {
              openItemPage(_listUuid, _itemUuid);
            },
            child: Container(
              decoration: BoxDecoration(
                color: _colorsApp.greyColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                      Text(
                          "x${_itemlist.quantity.toString()} ${getUnitText()}"),
                    ],
                  ),
                  leading: _itemImage,
                  trailing: Icon(
                    Icons.navigate_next,
                    color: BLACK,
                  ),
                ),
              ),
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

  openItemPage(String listUuid, String itemUuid) async {
    var updated = await Navigator.of(context).pushNamed(
      '/createItem',
      arguments: ItemArguments(listUuid: listUuid, itemUuid: itemUuid),
    );
    if (updated) {
      GetIt.I.get<ItemsListProvider>().fireUpdate();
    }
  }
}
