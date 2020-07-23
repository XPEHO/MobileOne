import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

const Color ORANGE = Colors.deepOrange;
const Color TRANSPARENT = Colors.transparent;

class CreateList extends StatefulWidget {
  State<StatefulWidget> createState() {
    return CreateListPage();
  }
}

class CreateListPage extends State<CreateList> {
  final _myController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  goToListsPage() {
    Navigator.pop(context);
  }

  void addItemToList() {
    GetIt.I.get<WishlistsListProvider>().addWishlist(_myController.text);
    goToListsPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  openListsPage();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 100.0),
              child: Container(
                height: 100,
                width: 100,
                child: Image.asset("assets/images/basket_create_list.png"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Card(
                elevation: 5,
                child: Container(
                  color: Colors.grey[200],
                  width: 300,
                  height: 70,
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
            ),
            RaisedButton(
              color: ORANGE,
              onPressed: () {
                addItemToList();
              },
              child: Text(getString(context, 'submit_button')),
            ),
          ],
        )),
      ),
    );
  }

  void openListsPage() {
    Navigator.pop(context);
  }
}
