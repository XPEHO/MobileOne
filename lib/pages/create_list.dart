import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uuid/uuid.dart';

const Color ORANGE = Colors.deepOrange;
const Color TRANSPARENT = Colors.transparent;

int itemCounts = 0;

class CreateList extends StatefulWidget {
  State<StatefulWidget> createState() {
    return CreateListPage();
  }
}

class CreateListPage extends State<CreateList> {
  final databaseReference = Firestore.instance;
  final _myController = TextEditingController();

  var _timeStamp = new DateTime.now();
  var uuid = Uuid();
  var isExist = false;

  addUsersListsToDataBase() async {
    await databaseReference
        .collection("/owners")
        .document(UserService().user.uid)
        .get()
        .then((value) {
      isExist = value.exists;
    });

    if (isExist) {
      await databaseReference
          .collection("/owners")
          .document(UserService().user.uid)
          .updateData({
        "Lists": FieldValue.arrayUnion([uuid.v4()]),
      });
    } else {
      await databaseReference
          .collection("/owners")
          .document(UserService().user.uid)
          .setData({
        "Lists": [uuid.v4()]
      });
    }
  }

  addListToDataBase() async {
    await databaseReference
        .collection("/wishlists")
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
    itemCounts++;
    await addListToDataBase();
    addUsersListsToDataBase();
    goToListsPage();
  }

  @override
  Widget build(BuildContext context) {
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
