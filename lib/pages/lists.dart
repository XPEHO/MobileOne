
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:MobileOne/pages/widget_list.dart';

const Color ORANGE = Colors.deepOrange;

class Lists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

String defaultImage = "assets/images/basket_my_lists.png";
String numberOfItemShared = "3 partages";

class ListsState extends State<Lists> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection("owners").document(UserService().user.uid).get().asStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        var wishlist = snapshot.data.data["lists"];
        return Scaffold(
          body: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 200.0, right: 300),
                child: Text(
                  getString(context, 'my_lists'),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: wishlist.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return WidgetLists(wishlist[index],
                        defaultImage, numberOfItemShared);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Text(
                  getString(context, 'shared_with_me'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}