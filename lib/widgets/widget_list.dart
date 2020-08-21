import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/utility/curvePainter.dart';

import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class WidgetLists extends StatefulWidget {
  final String listUuid;
  final String numberOfItemShared;
  WidgetLists({this.listUuid, this.numberOfItemShared});

  State<StatefulWidget> createState() => WidgetListsState();
}

class WidgetListsState extends State<WidgetLists> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistHeadProvider>(),
      child: Consumer<WishlistHeadProvider>(
        builder: (context, wishlistHeadProvider, child) {
          Wishlist wishlist = wishlistHeadProvider.getWishlist(widget.listUuid);
          if (wishlist == null) {
            return Center(
              child: Text(getString(context, "loading")),
            );
          }
          return CustomPaint(
            painter: CurvePainter(),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.23,
              height: MediaQuery.of(context).size.width * 0.05,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.05,
                      child: Text(
                        wishlist?.label ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: BLACK,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: Text(
                          "${wishlist?.itemCount} ${getString(context, 'items')}" ??
                              "",
                          style:
                              TextStyle(color: Colors.grey[900], fontSize: 8.0),
                        ),
                      ),
                      Container(
                        child: Text(
                          "${widget.numberOfItemShared} ${getString(context, 'shared')}" ??
                              "",
                          style:
                              TextStyle(color: Colors.grey[900], fontSize: 8.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
