import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';

import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class WidgetShareListWithSomeone extends StatefulWidget {
  final String _listUuid;
  WidgetShareListWithSomeone(this._listUuid);
  State<StatefulWidget> createState() {
    return WidgetShareListWithSomeoneState(_listUuid);
  }
}

class WidgetShareListWithSomeoneState
    extends State<WidgetShareListWithSomeone> {
  final String _listUuid;
  WidgetShareListWithSomeoneState(this._listUuid);
  var userService = GetIt.I.get<UserService>();
  var shareProvider = GetIt.I.get<ShareProvider>();
  final wishlistService = GetIt.I.get<WishlistService>();

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<ShareProvider>(),
      child: Consumer<ShareProvider>(
        builder: (context, shareProvider, child) {
          return Builder(
            builder: (BuildContext context) {
              return content(shareProvider.shareLists ?? {});
            },
          );
        },
      ),
    );
  }

  Widget content(Map<String, dynamic> lists) {
    List _emails = lists[_listUuid] ?? List();

    return Row(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 10,
                top: 10,
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.23,
                height: MediaQuery.of(context).size.width * 0.3,
                child: WidgetLists(
                  listUuid: _listUuid,
                  numberOfItemShared: _emails.length,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 120,
                top: 15,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width * 0.6,
                child: Column(
                  children: <Widget>[
                    Text(
                      getString(context, "shared_with"),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: WHITE,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _emails.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          var emailSelected = _emails[index];
                          return Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  _emails[index],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: WHITE,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  shareProvider.deleteShared(
                                      _listUuid, emailSelected);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/images/eraser.png',
                                    height: 15,
                                    width: 15,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
