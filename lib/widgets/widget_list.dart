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

  test() {}

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
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.12,
                        child: Text(
                          wishlist?.label ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: BLACK, fontSize: 12.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text(
                        "${wishlist?.itemCount} ${getString(context, 'items')}" ??
                            "",
                        style: TextStyle(color: GREY, fontSize: 8.0),
                      ),
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
