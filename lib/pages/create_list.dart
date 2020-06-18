import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/services/lists_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

const Color ORANGE = Colors.deepOrange;
const Color BLACK = Colors.black;
const Color WHITE = Colors.white;
const Color GREY = Colors.grey;
const Color TRANSPARENT = Colors.transparent;

var _listsService = GetIt.I.get<ListsService>();
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

  goToListsPage() {
   // Navigator.of(context).pop('/mainpage');
 Navigator.pushReplacementNamed(context, '/lists');
  }

  void addItemToList() {
    setState(() {
      _listsService.listOfNames.add(_myController.text);
      addListToDataBase();
    });
    
  }

  /*  initState() {
    super.initState();
   listsService.listOfNames.clear();
  //  getData();
  }*/


  @override
  Widget build(BuildContext context) {
    print("IM HERE CREATE LISTS");
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
              
                
              
              goToListsPage();
             // listsService.listOfNames.clear();
               // getData();
              
            },
            child: Text(getString(context, 'submit_button')),
          ),
        ],
      )),
    );
  }
}
