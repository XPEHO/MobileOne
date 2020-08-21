import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:MobileOne/utility/colors.dart';

class CreateList extends StatefulWidget {
  State<StatefulWidget> createState() {
    return CreateListPage();
  }
}

class CreateListPage extends State<CreateList> {
  final _myController = TextEditingController();
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnCreateListPage");
    super.initState();
  }

  void addListToDataBase() {
    GetIt.I.get<WishlistsListProvider>().addWishlist(_myController.text);
    FocusScope.of(context).unfocus();
    Navigator.popUntil(context, ModalRoute.withName('/mainPage'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 32.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: WHITE),
                    onPressed: () {
                      openListsPage();
                    },
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.3,
                child: Image.asset(
                  'assets/images/square-logo.png',
                ),
              ),
              Card(
                elevation: 5,
                child: Container(
                  color: _colorsApp.greyColor,
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Form(
                    child: TextFormField(
                      controller: _myController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: getString(context, "hint_name_new_list"),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: TRANSPARENT),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
              RaisedButton(
                color: _colorsApp.buttonColor,
                onPressed: () {
                  addListToDataBase();
                },
                child: Text(getString(context, 'submit_button')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openListsPage() {
    FocusScope.of(context).unfocus();
    Navigator.popUntil(context, ModalRoute.withName('/mainPage'));
  }
}
