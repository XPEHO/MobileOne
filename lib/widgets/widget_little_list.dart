import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/utility/curvePainter.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class WidgetLittleLists extends StatefulWidget {
  final String listUuid;
  final bool isGuest;
  WidgetLittleLists({@required this.listUuid, @required this.isGuest});

  State<StatefulWidget> createState() => WidgetLittleListsState();
}

class WidgetLittleListsState extends State<WidgetLittleLists> {
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
            painter: CurvePainter(wishlist),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.23,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
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
                      Text(
                        "${wishlist?.itemCount} ${getString(context, 'items')}" ??
                            "",
                        style:
                            TextStyle(color: Colors.grey[900], fontSize: 8.0),
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
