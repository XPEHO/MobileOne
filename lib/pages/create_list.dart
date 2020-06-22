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

  addListToDataBase() async {
    var newUuid = uuid.v4();
    List newWishlistsList = [];
    bool doesListExist = false;

    //Create a wishlist
    await databaseReference
        .collection("wishlists")
        .document(newUuid)
        .setData({
      'itemCounts': itemCounts.toString(),
      'label': _myController.text,
      'timestamp': _timeStamp,
    });

    //Check if the user already have a wishlist
    await Firestore.instance.collection("owners").document(UserService().user.uid).get().then((value) {
      doesListExist = value.exists;
    });

    //Create the document and set document's data to the new wishlist if the user does not have an existing wishlist
    //Or get the already existing wishlists, add the new one to the list and update the list in the database
    if (doesListExist) {
      await Firestore.instance.collection("owners").document(UserService().user.uid).get().then((value) {
        value.data.values.forEach((element) {
          newWishlistsList.add(element);
        });
      });
      newWishlistsList.add(["/wishlists/$newUuid"]);
      debugPrint("List : " + newWishlistsList.toString());
      try {
        await databaseReference.collection("owners").document(UserService().user.uid).updateData({"lists" : newWishlistsList});
      } catch (e) {
        debugPrint(e);
      }
    } else {
      newWishlistsList.add("/wishlists/$newUuid");
      await databaseReference.collection("owners").document(UserService().user.uid).setData({"lists" : newWishlistsList});
    }
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
