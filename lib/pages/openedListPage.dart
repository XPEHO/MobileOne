import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/listItem.dart';
import 'package:MobileOne/pages/wisget_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../localization/localization.dart';

const Color GREEN = Colors.green;
const Color GREY = Colors.grey;
const Color GREY600 = Colors.grey;
const Color RED = Colors.red;
const Color WHITE = Colors.white;
const Color TRANSPARENT = Colors.transparent;
  final itemNameController = new TextEditingController();
  final itemCountController = new TextEditingController();

  final databaseReference = Firestore.instance;

class OpenedListPage extends StatefulWidget {
  final String listUuid;

  OpenedListPage({Key key, this.listUuid}) : super(key: key);

  @override
  OpenedListPageState createState() => OpenedListPageState(this.listUuid);
}

class OpenedListPageState extends State<OpenedListPage> {
  final String listUuid;
  OpenedListPageState(this.listUuid);

  @override
  void dispose() {
    itemNameController.dispose();
    itemCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('items').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var _itemList = snapshot.data.documents;
          return Scaffold(
            body: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: <Widget>[
                    new ListView.builder(
                        padding: EdgeInsets.only(top: 30),
                        itemCount: _itemList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return WidgetItem(
                              _itemList[index].data["label"],
                              _itemList[index].data["quantity"].toString(),
                              _itemList[index].data["unit"],
                              listUuid);
                        }),
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        openListsPage();
                      },
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: FloatingActionButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                              WidgetPopup(getString(context, 'popup_add'), listUuid)
                          );
                        },
                        child: Icon(Icons.add),
                        backgroundColor: GREEN,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void openListsPage() {
    Navigator.pop(context);
  }
  
}
