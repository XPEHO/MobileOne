import 'package:MobileOne/localization/localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/pages/openedListPage.dart';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

const Color WHITE = Colors.white;
const Color BLACK = Colors.black;
const Color GREY = Colors.grey;
const Color RED = Colors.red;
const Color TRANSPARENT = Colors.transparent;

class WidgetPopup extends StatefulWidget {
  final String buttonName;
  final String listUuid;
  WidgetPopup(this.buttonName, this.listUuid);

  @override
  State<StatefulWidget> createState() {
    return WidgetPopupState(buttonName, listUuid);
  }
}

class WidgetPopupState extends State<WidgetPopup> {
  final String listUuid;
  final String buttonName;
  WidgetPopupState(this.buttonName, this.listUuid);

  String _name;
  int _count;
  String _type;

  String alert = "";
  TextEditingController labelPopup;

  String label = "";
  String quantity = "";
  String unit = "";
  Future<void> getItems() async {
    String labelValue;
    String quantityValue;
    String unitValue;
    /*await Firestore.instance
        .collection("items")
        .document("")
        .get()
        .then((value) {
      labelValue = value["label"];
      quantityValue = value["quantity"];

      unitValue = value["unit"];
    });
    setState(() {
      label = labelValue;
      quantity = quantityValue;
      unit = unitValue;
    });*/
  }

  @override
  void initState() {
      getItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
          15,
          170 - MediaQuery.of(context).viewInsets.top,
          15,
          170 - MediaQuery.of(context).viewInsets.bottom),
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
                controller: labelPopup,
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
                      controller: itemCountController,
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
                onPressed: () {
                  if (itemNameController == null ||
                      itemCountController == null ||
                      _type == null) {
                    setState(() {
                      alert = getString(context, "popup_alert");
                    });
                  } else {
                    addItemToList();
                  }
                },
                child: Text(
                  buttonName,
                  style: TextStyle(
                      color: Colors.grey[600], fontWeight: FontWeight.bold),
                ),
                color: WHITE,
              ),
              Text(
                alert,
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void clearPopupFields() {
    itemCountController.clear();
    itemNameController.clear();
    _name = null;
    _count = 0;
    _type = null;
  }

  void addItemToList() async {
    var uuid = Uuid();
    var newUuid = uuid.v4();
    bool doesDocumentExist = false;

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .get()
        .then((value) {
      doesDocumentExist = value.exists;
    });

    //Create the item
    if (doesDocumentExist == true) {
      await databaseReference.collection("items").document(listUuid).updateData({
        newUuid : {
          'label': _name,
          'quantity': _count,
          'unit': _type,
        }
      });
    } else {
      await databaseReference.collection("items").document(listUuid).setData({
        newUuid : {
          'label': _name,
          'quantity': _count,
          'unit': _type,
        }
      });
    }
   
    Navigator.of(context).pop();
    clearPopupFields();
  }

  void handleSubmittedItemCount(int input) {
    _count = input;
  }

  void handleSubmittedItemName(String input) {
    _name = input;
  }

  void incrementCounter() {
    itemCountController.text = (_count + 1).toString();
  }

  void decrementCounter() {
    if (_count > 0) {
      itemCountController.text = (_count - 1).toString();
    }
  }
}
