import 'dart:convert';

import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/widgets/bubble_button.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:MobileOne/icons/qr_code_icons.dart' as QrCodeIcon;
import 'package:MobileOne/utility/colors.dart' as CustomColors;

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
  final _itemNameFocusNode = FocusNode();
  final _itemQuantityFocusNode = FocusNode();
  String _name;
  int _count = 1;
  String _type;
  String imageLink = "assets/images/canned-food.png";

  String alert = "";
  String label = "";
  String quantity = "";
  String unit = "";

  var _itemsListProvider = GetIt.I.get<ItemsListProvider>();

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
    _itemNameFocusNode.requestFocus();
  }

  void getData() {
    if (buttonName == getString(context, "popup_update")) {
      getItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildTextField(context),
          SizedBox(
            height: 24,
          ),
          buildQuantity(context),
          buildUnit(context),
          SizedBox(
            height: 12,
          ),
          buildScanButton(context),
          SizedBox(
            height: 12,
          ),
          buildValidationButton(context),
          buildErrorMessage(),
        ],
      ),
    );
  }

  BubbleButton buildScanButton(BuildContext context) {
    return BubbleButton(
      icon: QrCodeIcon.QrCode.qrcode,
      color: Colors.lime[600],
      onPressed: () => scanAnItem(),
      iconColor: CustomColors.WHITE,
      height: 48,
      width: 48,
    );
  }

  Text buildErrorMessage() {
    return Text(
      alert,
      style: TextStyle(
          color: CustomColors.RED, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  Row buildValidationButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                getString(context, "close_item_creation"),
                style: TextStyle(
                    color: CustomColors.WHITE, fontWeight: FontWeight.bold),
              ),
              color: Colors.grey[400],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: RaisedButton(
              onPressed: () {
                _onValidate();
              },
              child: Text(
                buttonName,
                style: TextStyle(
                    color: CustomColors.WHITE, fontWeight: FontWeight.bold),
              ),
              color: Colors.lime[600],
            ),
          ),
        ),
      ],
    );
  }

  _onValidate() {
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
  }

  DropdownButtonFormField<String> buildUnit(BuildContext context) {
    final items = <String>[
      getString(context, 'item_unit'),
      getString(context, 'item_liters'),
      getString(context, 'item_grams'),
      getString(context, 'item_kilos')
    ];

    if (_type == null || _type.isEmpty) {
      _type = getString(context, 'item_unit');
    }

    return DropdownButtonFormField<String>(
      hint: Text(
        getString(context, 'item_type'),
      ),
      onChanged: (text) {
        setState(() {
          _type = text;
        });
      },
      value: _type,
      items: items.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value),
        );
      }).toList(),
    );
  }

  Row buildQuantity(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: BubbleButton(
            icon: Icons.remove,
            color: Colors.lime[600],
            onPressed: () => decrementCounter(),
            iconColor: CustomColors.WHITE,
          ),
        ),
        Expanded(
          flex: 1,
          child: TextField(
            focusNode: _itemQuantityFocusNode,
            onSubmitted: (_) => _onValidate(),
            inputFormatters: [
              LengthLimitingTextInputFormatter(5),
            ],
            style: TextStyle(
              fontSize: 18,
            ),
            key: Key("item_count_label"),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: CustomColors.TRANSPARENT),
              ),
              filled: true,
              fillColor: Colors.grey[300],
              hintText: getString(context, 'item_count'),
            ),
            keyboardType: TextInputType.number,
            controller: itemCountController,
            onChanged: (text) => handleSubmittedItemCount(int.parse(text)),
          ),
        ),
        Flexible(
          flex: 1,
          child: BubbleButton(
            onPressed: () => incrementCounter(),
            icon: Icons.add,
            color: Colors.lime[600],
            iconColor: CustomColors.WHITE,
          ),
        ),
      ],
    );
  }

  TextField buildTextField(BuildContext context) {
    return TextField(
      focusNode: _itemNameFocusNode,
      key: Key("item_name_label"),
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => _itemQuantityFocusNode.requestFocus(),
      decoration: InputDecoration(
        hintText: getString(context, 'item_name'),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CustomColors.TRANSPARENT),
        ),
        filled: true,
        fillColor: CustomColors.TRANSPARENT,
      ),
      controller: itemNameController,
      onChanged: (text) => handleSubmittedItemName(text),
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
    _itemsListProvider.updateItemInList(
        itemUuid, _name, _count, _type, imageLink);
    Navigator.of(context).pop();
    clearPopupFields();
  }

  void addItemToList() async {
    _itemsListProvider.addItemTolist(_name, _count, _type, imageLink);
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

  Future<void> scanAnItem() async {
    var result = await BarcodeScanner.scan();

    var response = await http.get(
        "https://world.openfoodfacts.org/api/v0/product/" +
            result.rawContent +
            ".json");
    Map<String, dynamic> article = jsonDecode(response.body);
    if (article["product"] != null) {
      itemNameController.text = article["product"]["product_name"].toString() +
          " - " +
          article["product"]["brands"].toString();
      handleSubmittedItemName(article["product"]["product_name"].toString() +
          " - " +
          article["product"]["brands"].toString());
      imageLink = article["product"]["image_small_url"];
    } else {
      setState(() {
        alert = getString(context, "cant_find_article");
      });
    }
  }
}
