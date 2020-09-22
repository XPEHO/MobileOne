import 'package:MobileOne/data/owner_details.dart';
import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:MobileOne/utility/curvePainter.dart';

import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class WidgetLists extends StatefulWidget {
  final String listUuid;
  final bool isGuest;
  WidgetLists({@required this.listUuid, @required this.isGuest});

  State<StatefulWidget> createState() => WidgetListsState();
}

class WidgetListsState extends State<WidgetLists> {
  final _wishlistService = GetIt.I.get<WishlistService>();
  CircleAvatar _avatar = CircleAvatar(
    backgroundColor: WHITE,
    child: Icon(
      Icons.person,
      color: Colors.grey,
      size: 15,
    ),
    radius: 15.0,
  );
  Widget _email = Container();
  OwnerDetails ownerDetails;

  getOwnerDetails() async {
    ownerDetails = await _wishlistService.getOwnerDetails(widget.listUuid);
    if (ownerDetails != null && ownerDetails.path != null) {
      setState(() {
        _avatar = CircleAvatar(
          backgroundColor: WHITE,
          backgroundImage: NetworkImage(ownerDetails.path),
          radius: 15.0,
        );
      });
    }
    if (ownerDetails != null && ownerDetails.email != null) {
      setState(() {
        _email = Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Center(
            child: Text(
              ownerDetails.email.substring(0, 2).toUpperCase(),
              style: TextStyle(
                  color: BLACK, fontSize: 12.0, fontWeight: FontWeight.bold),
            ),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    if (widget.isGuest) {
      getOwnerDetails();
    }
    super.initState();
  }

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
                  widget.isGuest
                      ? MediaQuery.of(context).size.height <= 800 &&
                              MediaQuery.of(context).size.width <= 480
                          ? _email
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: _avatar,
                            )
                      : Container(),
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
