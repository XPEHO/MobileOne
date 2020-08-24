import 'package:MobileOne/data/wishlist.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/share_provider.dart';
import 'package:MobileOne/providers/wishlist_head_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/widgets/widget_list.dart';
import 'package:MobileOne/pages/share_one.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class ShareTwo extends StatefulWidget {
  ShareStateTwoState createState() => ShareStateTwoState();
}

class ShareStateTwoState extends State<ShareTwo> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  final _myController = TextEditingController();

  var userService = GetIt.I.get<UserService>();
  var shareProvider = GetIt.I.get<ShareProvider>();
  var _colorsApp = GetIt.I.get<ColorService>();
  var wishlistHeadProvider = GetIt.I.get<WishlistHeadProvider>();
  String _filterText = "";

  void initState() {
    _analytics.setCurrentPage("isOneShareTwoPage");
    super.initState();
    _myController.text = _filterText;
  }

  filterLists(String value) {
    setState(() {
      _filterText = value;
    });
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistHeadProvider>(),
      child: Consumer<WishlistHeadProvider>(builder: (context, provider, _) {
        return Builder(builder: (BuildContext context) {
          return buildShareList(provider.filteredLists(_filterText));
        });
      }),
    );
  }

  Scaffold buildShareList(List<Wishlist> wishlists) {
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildeAppBar(),
            buildHeader(),
            Container(
              color: WHITE,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: getString(context, "share_list"),
                    suffixIcon: Icon(
                      Icons.search,
                      color: BLACK,
                    ),
                  ),
                  controller: _myController,
                  onChanged: (value) {
                    setState(
                      () {
                        filterLists(value);
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 50.0,
                right: 300,
              ),
              child: Text(
                getString(context, 'my_lists'),
                style: TextStyle(
                  color: WHITE,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: wishlists.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return GestureDetector(
                          onTap: () {
                            final _selectedUuid = wishlists[index].uuid;
                            if (searchTermEmail != null) {
                              shareProvider.addSharedToDataBase(
                                  searchTermEmail.toLowerCase(), _selectedUuid);
                              shareProvider.addGuestToDataBase(
                                  searchTermEmail.toLowerCase(), _selectedUuid);
                              openSharePage();
                            } else {
                              shareProvider.addSharedToDataBase(
                                  contactSelected.emails.elementAt(0).value,
                                  _selectedUuid);
                              shareProvider.addGuestToDataBase(
                                  contactSelected.emails.elementAt(0).value,
                                  _selectedUuid);
                              openSharePage();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 100,
                              child: WidgetLists(
                                listUuid: wishlists[index].uuid,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildeAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        top: 30,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: WHITE,
                ),
                onPressed: () {
                  openSharePage();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 7,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  getString(context, "which_list"),
                  style: TextStyle(
                    fontSize: 20,
                    color: WHITE,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 100, right: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CircleAvatar(
            child: Text(
              getString(context, "step_one"),
              style: TextStyle(
                color: WHITE,
                fontSize: 10,
              ),
            ),
            radius: 12,
            backgroundColor: _colorsApp.buttonColor,
          ),
          Expanded(
            child: Divider(
              color: WHITE,
              height: 80,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          ),
          CircleAvatar(
            child: Text(
              getString(context, "step_two"),
              style: TextStyle(
                color: WHITE,
                fontSize: 10,
              ),
            ),
            radius: 12,
            backgroundColor: _colorsApp.buttonColor,
          ),
        ],
      ),
    );
  }

  void openSharePage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainPage"));
  }
}
