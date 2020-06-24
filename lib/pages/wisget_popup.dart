import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/pages/openedListPage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

const Color WHITE = Colors.white;
const Color BLACK = Colors.black;
const Color GREY = Colors.grey;
const Color TRANSPARENT = Colors.transparent;

class WidgetPopup extends StatefulWidget {
  String buttonName;
  WidgetPopup(this.buttonName);

  @override
  State<StatefulWidget> createState() {
    return WidgetPopupState(buttonName);
  }
}

class WidgetPopupState extends State<WidgetPopup> {
  String _name;
  int _count;
  String _type;
  String buttonName;
  WidgetPopupState(this.buttonName);
  String alert="";
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
              Text(alert, style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),),
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
    await databaseReference.collection("items").document(uuid.v4()).setData({
      'label': _name,
      'quantity': _count,
      'unit': _type,
    });
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
