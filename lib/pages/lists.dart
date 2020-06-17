import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/lists_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:MobileOne/pages/pattern_list.dart';
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
  @override
  Widget build(BuildContext context) {
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
