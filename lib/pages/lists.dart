import 'package:MobileOne/localization/localization.dart';

import 'package:MobileOne/services/lists_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:MobileOne/pages/pattern_list.dart';

import 'package:get_it/get_it.dart';

const Color ORANGE = Colors.deepOrange;
var listsService = GetIt.I.get<ListsService>();
List<String> l = [];

class Lists extends StatefulWidget {
  Lists({this.app});
  final FirebaseApp app;
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> {
  getData() {
    final databaseReference = Firestore.instance;
    databaseReference
        .collection("wishlists")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => l.add(f.data["label"].toString()));
      setState(() {
        for (int i = 0; i < l.length; i++) {
          listsService.listOfNames.add(l[i].toString());
        }
      });
    });
  }

  initState() {
    super.initState();
    listsService.listOfNames.clear();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    print("IM HERE lists");
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
              itemCount: listsService.listOfNames.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return patternLists(context, listsService.listOfNames[index]);
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
  }
}
