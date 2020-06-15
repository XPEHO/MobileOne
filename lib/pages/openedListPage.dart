import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/listItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../localization/localization.dart';

const Color GREEN = Colors.green;
const Color GREY = Colors.grey;
const Color GREY600 = Colors.grey;
const Color RED = Colors.red;
const Color WHITE = Colors.white;
const Color TRANSPARENT = Colors.transparent;

class OpenedListPage extends StatefulWidget {
  OpenedListPage({Key key}) : super(key: key);

  @override
  OpenedListPageState createState() => OpenedListPageState();
}

class OpenedListPageState extends State<OpenedListPage> {
  final _itemNameController = new TextEditingController();
  final _itemCountController = new TextEditingController();
  final databaseReference = Firestore.instance;
  String _name;
  int _count;
  String _type;

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemCountController.dispose();
    super.dispose();
  }

  void handleSubmittedItemCount(int input) {
    _count = input;
  }

  void handleSubmittedItemName(String input) {
    _name = input;
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
                          return itemWidget(
                              ctxt,
                              _itemList[index].data["label"],
                              _itemList[index].data["quantity"].toString(),
                              _itemList[index].data["unit"]);
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
                                _buildAddItemDialog(context),
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

  Widget _buildAddItemDialog(BuildContext context) {
    return new AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
          10,
          180 - MediaQuery.of(context).viewInsets.top,
          10,
          180 - MediaQuery.of(context).viewInsets.bottom),
      content: new Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                key: Key("item_name_label"),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: getString(context, 'item_name'),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: TRANSPARENT),
                  ),
                  filled: true,
                  fillColor: TRANSPARENT,
                ),
                controller: _itemNameController,
                onChanged: (text) => handleSubmittedItemName(text),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 35,
                    child: FloatingActionButton(
                      onPressed: () => decrementCounter(),
                      child: Icon(Icons.remove),
                      backgroundColor: RED,
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 35,
                    child: TextField(
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(5),
                      ],
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      key: Key("item_count_label"),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: TRANSPARENT),
                        ),
                        filled: true,
                        fillColor: Colors.grey[300],
                        hintText: getString(context, 'item_count'),
                      ),
                      keyboardType: TextInputType.number,
                      controller: _itemCountController,
                      onChanged: (text) =>
                          handleSubmittedItemCount(int.parse(text)),
                    ),
                  ),
                  Container(
                    width: 35,
                    child: FloatingActionButton(
                      onPressed: () => incrementCounter(),
                      child: Icon(Icons.add),
                      backgroundColor: RED,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              DropdownButtonFormField<String>(
                hint: Text(
                  getString(context, 'item_type'),
                ),
                onChanged: (text) {
                  setState(() {
                    _type = text;
                  });
                },
                value: _type,
                items: <String>[
                  getString(context, 'item_unit'),
                  getString(context, 'item_liters'),
                  getString(context, 'item_grams'),
                  getString(context, 'item_kilos')
                ].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 5,
              ),
              RaisedButton(
                onPressed: () => addItemToList(),
                child: Text(
                  getString(context, 'add_item'),
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
                color: WHITE,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void incrementCounter() {
    _itemCountController.text = (_count + 1).toString();
  }

  void decrementCounter() {
    if (_count > 0) {
      _itemCountController.text = (_count - 1).toString();
    }
  }

  void addItemToList() async {
    var uuid = Uuid();
    await databaseReference.collection("items").document(uuid.v4()).setData({
      'label': _name,
      'quantity': _count,
      'unit': _type,
    });
    Navigator.of(context).pop();
    clearPopupFields();
  }

  void clearPopupFields() {
    _itemCountController.clear();
    _itemNameController.clear();
    _name = null;
    _count = 0;
    _type = null;
  }

  void openListsPage() {
    Navigator.pop(context);
  }
}
