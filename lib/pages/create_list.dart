import 'package:MobileOne/localization/localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uuid/uuid.dart';

const Color ORANGE = Colors.deepOrange;
const Color TRANSPARENT = Colors.transparent;

int itemCounts = 0;

class CreateList extends StatefulWidget {
  CreateList({this.app});
  final FirebaseApp app;

  State<StatefulWidget> createState() {
    return CreateListPage();
  }
}

class CreateListPage extends State<CreateList> {
  final databaseReference = Firestore.instance;
  final _myController = TextEditingController();

  var _timeStamp = new DateTime.now();
  var uuid = Uuid();
  addListToDataBase() async {
    await databaseReference
        .collection("wishlists")
        .document(uuid.v4())
        .setData({
      'itemCounts': itemCounts.toString(),
      'label': _myController.text,
      'timestamp': _timeStamp,
    });
  }

  goToListsPage() {
    Navigator.pop(context);
  }

  void addItemToList() async {
    await addListToDataBase();
    goToListsPage();
  }

  @override
  Widget build(BuildContext context) {
    print("IM HERE CREATE LISTS");

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
    );
  }
}
