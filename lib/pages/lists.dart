import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/lists_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:MobileOne/pages/pattern_list.dart';
import 'package:MobileOne/pages/create_list.dart';
import 'package:get_it/get_it.dart';

const Color ORANGE = Colors.deepOrange;
 var _listsService = GetIt.I.get<ListsService>();

class Lists extends StatefulWidget {
  Lists({this.app});
  final FirebaseApp app;
  State<StatefulWidget> createState() {
    return ListsState();
  }
}


class ListsState extends State<Lists> {

  List<String> l =[];


test(){
 
 final databaseReference = Firestore.instance;
    databaseReference
        .collection("wishlists")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
       snapshot.documents.forEach((f) => l.add(f.data["label"].toString()));
       //snapshot.documents.forEach((f) => print(f.data["label"].toString()));
    });

    
     
}
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
 
    test();
  }

  @override
  Widget build(BuildContext context) {

         for(int i=0;i<l.length;i++){
 _listsService.listOfNames.add(l[i].toString());

    }
  
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
              itemCount: _listsService.listOfNames.length,
              itemBuilder: (BuildContext ctxt, int index) {
              
    return patternLists(context, _listsService.listOfNames[index]);
  
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
