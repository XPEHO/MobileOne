import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';

import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistHeadProvider>(),
      child: Consumer<WishlistHeadProvider>(
        builder: (context, wishlistHeadProvider, child) {
          Wishlist wishlist = wishlistHeadProvider.getWishlist(_listUuid);
          if (wishlist == null) {
            wishlistHeadProvider.fetchWishlist(_listUuid);
          }
          return Container(
            width: MediaQuery.of(context).size.width * 0.23,
            height: MediaQuery.of(context).size.width * 0.05,
            child: Card(
              elevation: 3,
              color: WHITE,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(
                        wishlist?.label ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: BLACK, fontSize: 12.0),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.23 / 2,
                      child: Image.asset("assets/images/basket_my_lists.png"),
                    ),
                    Text(
                      "${wishlist?.itemCount} ${getString(context, 'articles')}" ??
                          "",
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
        },
      ),
    );
  }
}
