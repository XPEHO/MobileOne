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
      size: 24,
    ),
    radius: 24.0,
  );
  OwnerDetails ownerDetails;
  Widget _email = Container();

  getOwnerDetails() async {
    ownerDetails = await _wishlistService.getOwnerDetails(widget.listUuid);
    if (ownerDetails != null && ownerDetails.path != null) {
      setState(() {
        _avatar = CircleAvatar(
          backgroundColor: WHITE,
          backgroundImage: NetworkImage(ownerDetails.path),
          radius: 24.0,
        );
      });
    }
    if (ownerDetails != null && ownerDetails.email != null) {
      setState(() {
        _email = Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Center(
            child: FittedBox(
              child: Text(
                ownerDetails.email,
                style: TextStyle(color: BLACK, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    getOwnerDetails();
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
              width: MediaQuery.of(context).size.width * 0.75,
              child: Column(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Center(
                      child: Text(
                        wishlist?.label ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: BLACK,
                            fontWeight: FontWeight.bold,
                            fontSize: 32.0),
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: _avatar,
                        ),
                        _email,
                      ],
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              child: Text(
                                "${wishlist?.itemCount} ${getString(context, 'items')}" ??
                                    "",
                                style: TextStyle(color: Colors.grey[900]),
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                wishlist?.progression != null
                                    ? "${wishlist?.progression} %"
                                    : "${getString(context, 'null_progression')}",
                                style: TextStyle(color: Colors.grey[900]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
