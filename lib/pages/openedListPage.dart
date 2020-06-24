import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/widget_item.dart';
import 'package:MobileOne/pages/widget_list.dart';
import 'package:MobileOne/pages/widget_popup.dart';
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
 String listUuid;
class OpenedListPage extends StatefulWidget {
  OpenedListPage({Key key,}) : super(key: key);

  @override
  OpenedListPageState createState() => OpenedListPageState();
}

class OpenedListPageState extends State<OpenedListPage> {


  String label = "";
  String count = "";

  Future<void> getListDetails() async {
    String labelValue;
    String countValue;

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .get()
        .then((value) {
      labelValue = value["label"];
    });

    setState(() {
      label = labelValue;
      test=label;
    });
  }

  @override
  void initState() {
    getListDetails();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    listUuid = ModalRoute.of(context).settings.arguments;
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('items')
            .document(listUuid)
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var wishlist = snapshot?.data?.data ?? {};
          return Scaffold(
            body: SafeArea(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: <Widget>[
                    new ListView.builder(
                        padding: EdgeInsets.only(top: 30),
                        itemCount: wishlist.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return WidgetItem(
                            wishlist.values.toList()[index], listUuid
                          );
                        }),
                    Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                        child:IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            openListsPage();
                          },
                        ),),
                        Padding(
                          padding: EdgeInsets.only(top:7),
                          child:Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            test,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),),
                      ],
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
                          ).then((value) => setState(() {}));
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