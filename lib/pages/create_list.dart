import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/pattern_list.dart';
import 'package:flutter/material.dart';

final myController = TextEditingController();
const Color ORANGE = Colors.deepOrange;
const Color BLACK = Colors.black;
const Color WHITE = Colors.white;
const Color GREY = Colors.grey;
const Color TRANSPARENT = Colors.transparent;

class CreateList extends StatefulWidget {
  State<StatefulWidget> createState() {
    return CreateListPage();
  }
}

class CreateListPage extends State<CreateList> {
  goToListsPage() {
    Navigator.pop(context);
  }

  void addItemToList() {
    widgetList.add(patternLists(context));
  }

  @override
  Widget build(BuildContext context) {
    Lists();
    return Scaffold(
      body: Center(
          child: Column(
        children: <Widget>[
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
                    controller: myController,
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
              goToListsPage();
            },
            child: Text(getString(context, 'submit_button')),
          ),
        ],
      )),
    );
  }
}
