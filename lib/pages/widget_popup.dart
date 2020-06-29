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

class EditItemPopup extends StatefulWidget {
  final String buttonName;
  final String listUuid;
  final String itemUuid;
  EditItemPopup(this.buttonName, this.listUuid, this.itemUuid);

  @override
  State<StatefulWidget> createState() {
    return EditItemPopupState(buttonName, listUuid, itemUuid);
  }
}

class EditItemPopupState extends State<EditItemPopup> {
  final String listUuid;
  final String itemUuid;
  final String buttonName;

  EditItemPopupState(this.buttonName, this.listUuid, this.itemUuid);
  final itemNameController = new TextEditingController();
  final itemCountController = new TextEditingController();
  String _name;
  int _count = 1;
  String _type;
  int _itemCount = 0;

  String alert = "";
  String label = "";
  String quantity = "";
  String unit = "";

  Future<void> getItems() async {
    String labelValue;
    String quantityValue;
    String unitValue;

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .get()
        .then((value) {
      labelValue = value[itemUuid]["label"];
      quantityValue = value[itemUuid]["quantity"].toString();
      unitValue = value[itemUuid]["unit"];
    });

    setState(() {
      itemNameController.text = labelValue;
      itemCountController.text = quantityValue;
      _type = unitValue;
      _name = labelValue;
      _count = int.parse(quantityValue);
    });
  }

  @override
  void initState() {
    itemCountController.text = "1";
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
    super.initState();
  }

  void getData() {
    if (buttonName == getString(context, "popup_update")) {
      getItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(
          15,
          120 - MediaQuery.of(context).viewInsets.top,
          15,
          120 - MediaQuery.of(context).viewInsets.bottom),
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
                controller: itemNameController,
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
                      _type == null ||
                      itemNameController.text == "" ||
                      itemCountController.text == "") {
                    setState(() {
                      alert = getString(context, "popup_alert");
                    });
                  } else {
                    if (buttonName == getString(context, "popup_update")) {
                      uddapteItemInList();
                    } else {
                      addItemToList();
                    }
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
    _count = 1;
    _type = null;
  }

  void uddapteItemInList() async {
    await databaseReference.collection("items").document(listUuid).updateData({
      itemUuid: {
        'itemCount': _itemCount++,
        'label': _name,
        'quantity': _count,
        'unit': _type,
      }
    });
    Navigator.of(context).pop();
    clearPopupFields();
  }

  void addItemToList() async {
    var uuid = Uuid();
    var newUuid = uuid.v4();
    var listItemsCount;
    bool doesDocumentExist = false;

    await Firestore.instance
        .collection("wishlists")
        .document(listUuid)
        .get()
        .then((value) {
      listItemsCount = value["itemCounts"];
    });

    await databaseReference
        .collection("wishlists")
        .document(listUuid)
        .updateData({"itemCounts": (int.parse(listItemsCount) + 1).toString()});

    await Firestore.instance
        .collection("items")
        .document(listUuid)
        .get()
        .then((value) {
      doesDocumentExist = value.exists;
    });

    //Create the item
    if (doesDocumentExist == true) {
      await databaseReference
          .collection("items")
          .document(listUuid)
          .updateData({
        newUuid: {
          'label': _name,
          'quantity': _count,
          'unit': _type,
        }
      });
    } else {
      await databaseReference.collection("items").document(listUuid).setData({
        newUuid: {
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
    _count = _count + 1;
    itemCountController.text = (_count).toString();
  }

  void decrementCounter() {
    if (_count > 0) {
      _count = _count - 1;
      itemCountController.text = (_count).toString();
    }
  }
}
