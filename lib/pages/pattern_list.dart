import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/pages/create_list.dart';

Widget patternLists(BuildContext context,String objectName) {
  final databaseReference = Firestore.instance;

  List l = [];

   getData() {
    databaseReference
        .collection("wishlists")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => l.add(f.data));
    });
  }
  getData();
/*
String test(){
String name;
    itemCounts++;
    for (int i = 0; i < l.length; i++) {
      name = getData()[i].toString();
    }
    return name;
}*/
    print(l.length);

  return Container(
    width: MediaQuery.of(context).size.width * 0.23,
    child: Card(
      elevation: 3,
      color: Colors.white,
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Text(
                objectName,
                //test(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: BLACK, fontSize: 12.0),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.23 / 2,
              child: Image.asset("assets/images/basket_my_lists.png"),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                "Example",
                style: TextStyle(color: GREY, fontSize: 10.0),
              ),
            ),
            Text(
              "Example",
              style: TextStyle(color: GREY, fontSize: 10.0),
            ),
          ],
        ),
      ),
    ),
  );
}
