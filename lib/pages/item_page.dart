import 'dart:convert';
import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/services/image_service.dart';
import 'dart:io';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/itemsList_provider.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/bubble_button.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class EditItemPage extends StatefulWidget {
  EditItemPage({
    Key key,
  }) : super(key: key);

  @override
  EditItemPageState createState() => EditItemPageState();
}

class EditItemPageState extends State<EditItemPage> {
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
  var _imageService = GetIt.I.get<ImageService>();

  ItemArguments _args;
  var _itemImage;
  File pickedImage;

  Future<void> getItems() async {
    String labelValue;
    String quantityValue;
    String unitValue;

    await Firestore.instance
        .collection("items")
        .document(_args.listUuid)
        .get()
        .then((value) {
      labelValue = value[_args.itemUuid]["label"];
      quantityValue = value[_args.itemUuid]["quantity"].toString();
      imageLink = value[_args.itemUuid]["image"];
      if (imageLink != "assets/images/canned-food.png") {
        _itemImage = NetworkImage(imageLink);
      }
      switch (value[_args.itemUuid]["unit"]) {
        case 1:
          unitValue = getString(context, 'item_unit');
          break;
        case 2:
          unitValue = getString(context, 'item_liters');
          break;
        case 3:
          unitValue = getString(context, 'item_grams');
          break;
        case 4:
          unitValue = getString(context, 'item_kilos');
          break;
        default:
          unitValue = getString(context, 'item_unit');
          break;
      }
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
    _itemImage = AssetImage("assets/images/canned-food.png");
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
    super.initState();
    _itemNameFocusNode.requestFocus();
  }

  void getData() {
    if (_args.buttonName == getString(context, "popup_update")) {
      getItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    _args = Arguments.value(context);
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            }),
        iconTheme: ThemeData.light().iconTheme,
        actionsIconTheme: ThemeData.light().iconTheme,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset(
              "assets/images/qr-code.svg",
              color: Colors.lime[600],
              width: 24,
              height: 24,
            ),
            onPressed: () => scanAnItem(),
          ),
          IconButton(
            key: Key("item_picture_button"),
            icon: Icon(
              Icons.camera,
              color: Colors.lime[600],
              size: 24,
            ),
            onPressed: () {
              pickImage();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: buildTextField(context)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: buildQuantity(context)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    child: buildUnit(context)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    child: Image(image: _itemImage)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: buildValidationButton(context)),
                Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: buildErrorMessage()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    await _imageService
        .pickCamera()
        .then((image) => pickedImage = File(image.path));

    StorageReference storageReference =
        _imageService.uploadFile(_args.listUuid, pickedImage);
    StorageUploadTask uploadTask = storageReference.putFile(pickedImage);
    await uploadTask.onComplete;
    storageReference.getDownloadURL().then((fileURL) {
      imageLink = fileURL;
    });

    setState(() {
      _itemImage = FileImage(pickedImage);
    });
  }

  Text buildErrorMessage() {
    return Text(
      alert,
      style: TextStyle(color: RED, fontWeight: FontWeight.bold, fontSize: 12),
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
                _onValidate();
              },
              child: Text(
                _args.buttonName,
                style: TextStyle(color: WHITE, fontWeight: FontWeight.bold),
              ),
              color: Colors.lime[600],
            ),
          ),
        ),
      ],
    );
  }

  int getTypeIndex() {
    if (_type == getString(context, 'item_unit')) {
      return 1;
    } else if (_type == getString(context, 'item_liters')) {
      return 2;
    } else if (_type == getString(context, 'item_grams')) {
      return 3;
    } else if (_type == getString(context, 'item_kilos')) {
      return 4;
    } else {
      return 1;
    }
  }

  _onValidate() async {
    if (itemNameController == null ||
        itemCountController == null ||
        _type == null ||
        itemNameController.text == "" ||
        itemCountController.text == "") {
      setState(() {
        alert = getString(context, "popup_alert");
      });
    } else {
      int _typeIndex = getTypeIndex();
      if (_args.buttonName == getString(context, "popup_update")) {
        uddapteItemInList(_typeIndex);
      } else {
        addItemToList(_typeIndex);
      }
    }
  }

  Widget buildUnit(BuildContext context) {
    final items = <String>[
      getString(context, 'item_unit'),
      getString(context, 'item_liters'),
      getString(context, 'item_grams'),
      getString(context, 'item_kilos')
    ];

    if (_type == null || _type.isEmpty) {
      _type = getString(context, 'item_unit');
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TRANSPARENT),
          ),
          filled: true,
          fillColor: Colors.grey[300],
        ),
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
      ),
    );
  }

  Widget buildQuantity(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            getString(context, 'quantity'),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: BubbleButton(
                icon: Icon(Icons.remove, color: WHITE),
                color: Colors.lime[600],
                onPressed: () => decrementCounter(),
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
                    borderSide: BorderSide(color: TRANSPARENT),
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
                icon: Icon(Icons.add, color: WHITE),
                color: Colors.lime[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        focusNode: _itemNameFocusNode,
        key: Key("item_name_label"),
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _itemQuantityFocusNode.requestFocus(),
        decoration: InputDecoration(
          hintText: getString(context, 'item_name'),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: TRANSPARENT),
          ),
          filled: true,
          fillColor: Colors.grey[300],
        ),
        controller: itemNameController,
        onChanged: (text) => handleSubmittedItemName(text),
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

  void uddapteItemInList(int _typeIndex) async {
    await _itemsListProvider.updateItemInList(
      itemUuid: _args.itemUuid,
      name: _name,
      count: _count,
      typeIndex: _typeIndex,
      imageLink: imageLink,
      listUuid: _args.listUuid,
    );
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    clearPopupFields();
  }

  void addItemToList(int _typeIndex) async {
    await _itemsListProvider.addItemTolist(
      name: _name,
      count: _count,
      typeIndex: _typeIndex,
      imageLink: imageLink,
      listUuid: _args.listUuid,
    );
    FocusScope.of(context).unfocus();
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
      setState(() {
        _itemImage = NetworkImage(imageLink);
      });
    } else {
      setState(() {
        alert = getString(context, "cant_find_article");
      });
    }
  }
}
