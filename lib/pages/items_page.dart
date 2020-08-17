import 'dart:convert';
import 'package:MobileOne/services/color_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/analytics_services.dart';
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
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path/path.dart' as path;

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
  var _analytics = GetIt.I.get<AnalyticsService>();
  String _name;
  int _count = 1;
  String _type;
  String imageLink = "assets/images/canned-food.png";
  String _imageName;
  String _oldImageName;

  String alert = "";
  String label = "";
  String quantity = "";
  String unit = "";

  var _itemsListProvider = GetIt.I.get<ItemsListProvider>();
  var _imageService = GetIt.I.get<ImageService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  ItemArguments _args;
  var _itemImage;
  File pickedImage;
  final SpeechToText speech = SpeechToText();
  bool isInitialized;
  String imageType = "Default";

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
      if (value[_args.itemUuid]["imageName"] != null) {
        _imageName = value[_args.itemUuid]["imageName"];
      }
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
    _analytics.setCurrentPage("isOnItemsPage");
    itemCountController.text = "1";
    _itemImage = AssetImage("assets/images/canned-food.png");
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
    super.initState();
    _itemNameFocusNode.requestFocus();
    initializeSpeech();
  }

  initializeSpeech() async {
    isInitialized = await speech.initialize();
  }

  void getData() {
    if (_args.buttonName == getString(context, "popup_update")) {
      _analytics.sendAnalyticsEvent("update_item");
      getItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    _args = Arguments.value(context);
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          color: WHITE,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.height * 0.40,
                          child: Image(image: _itemImage),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                              ),
                              onPressed: () {
                                goToPreviousPage();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.height * 0.40,
                      color: Colors.lime[600],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: WHITE,
                              size: 24,
                            ),
                            onPressed: () => recordAudio(),
                          ),
                          IconButton(
                            icon: SvgPicture.asset(
                              "assets/images/qr-code.svg",
                              color: WHITE,
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () => scanAnItem(),
                          ),
                          IconButton(
                            key: Key("item_picture_button"),
                            icon: Icon(
                              Icons.camera,
                              color: WHITE,
                              size: 24,
                            ),
                            onPressed: () {
                              _analytics
                                  .sendAnalyticsEvent("takePictureOfItem");
                              pickImage();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    child: buildTextField(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: buildQuantity(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.10,
                    width: MediaQuery.of(context).size.height * 0.7,
                    child: buildUnit(context),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: buildValidationButton(context)),
                ),
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

  recordAudio() async {
    if (isInitialized) {
      await buildRecordPopup();
      await speech.cancel();
      await speech.stop();
    } else {
      Fluttertoast.showToast(msg: getString(context, 'microphone_access'));
    }
  }

  listenRecord() async {
    await speech.listen(
      partialResults: false,
      onResult: (result) {
        setState(() {
          itemNameController.text = result.recognizedWords;
          _name = result.recognizedWords;
          Navigator.of(context).pop();
        });
      },
    );
  }

  Future<bool> buildRecordPopup() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          listenRecord();
          return new AlertDialog(
            backgroundColor: _colorsApp.microColor,
            scrollable: true,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.mic,
                    color: WHITE,
                    size: 36,
                  ),
                  Text(
                    getString(context, "talk"),
                    style: TextStyle(color: WHITE),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> pickImage() async {
    await _imageService
        .pickCamera()
        .then((image) => pickedImage = File(image.path));

    setState(() {
      _itemImage = FileImage(pickedImage);
    });

    imageType = "Picked";
  }

  Text buildErrorMessage() {
    return Text(
      alert,
      style: TextStyle(color: RED, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  RaisedButton buildValidationButton(BuildContext context) {
    return RaisedButton(
      color: Colors.lime[600],
      onPressed: () {
        _onValidate();
      },
      child: Text(
        _args.buttonName,
        style: TextStyle(color: WHITE, fontWeight: FontWeight.bold),
      ),
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
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: TRANSPARENT),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            filled: true,
            fillColor: _colorsApp.greyColor,
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
              child:
                  new Text(value, style: TextStyle(color: GREY, fontSize: 13)),
            );
          }).toList(),
        ),
      ),
    );
  }

  Row buildQuantity(BuildContext context) {
    return Row(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
        ),
        Container(
          child: BubbleButton(
            icon: Icon(Icons.remove, color: WHITE),
            color: Colors.lime[600],
            onPressed: () => decrementCounter(),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.2,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
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
        ),
        Container(
          child: BubbleButton(
            icon: Icon(Icons.add, color: WHITE),
            color: Colors.lime[600],
            onPressed: () => incrementCounter(),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.25,
        ),
      ],
    );
  }

  Widget buildTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
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
      if (_args.buttonName == getString(context, "popup_update")) {
        waitForImageUpload(true);
      } else {
        waitForImageUpload(false);
      }
    }
  }

  void waitForImageUpload(bool upload) {
    int _typeIndex = getTypeIndex();
    _oldImageName = _imageName;
    if (imageType == "Picked") {
      StorageReference ref = getStorageRef();
      StorageUploadTask uploadTask = uploadItemPicture(ref);
      uploadTask.onComplete.then((_) {
        ref.getDownloadURL().then((fileURL) {
          imageLink = fileURL;
          if (upload) {
            updapteItemInList(_typeIndex);
            if (_oldImageName != null) {
              _imageService.deleteFile(_args.listUuid, _oldImageName);
            }
          } else {
            addItemToList(_typeIndex);
          }
        });
      });
    } else if (imageType == "Scanned") {
      _imageName = null;
      if (upload) {
        updapteItemInList(_typeIndex);
        if (_oldImageName != null) {
          _imageService.deleteFile(_args.listUuid, _oldImageName);
        }
      } else {
        addItemToList(_typeIndex);
      }
    } else {
      if (upload) {
        updapteItemInList(_typeIndex);
      } else {
        addItemToList(_typeIndex);
      }
    }
  }

  void updapteItemInList(int _typeIndex) async {
    _analytics.sendAnalyticsEvent("update_item");
    await _itemsListProvider.updateItemInList(
      itemUuid: _args.itemUuid,
      name: _name,
      count: _count,
      typeIndex: _typeIndex,
      imageLink: imageLink,
      listUuid: _args.listUuid,
      imageName: _imageName,
    );
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    clearPopupFields();
  }

  void addItemToList(int _typeIndex) async {
    _analytics.sendAnalyticsEvent("add_item");
    await _itemsListProvider.addItemTolist(
      name: _name,
      count: _count,
      typeIndex: _typeIndex,
      imageLink: imageLink,
      listUuid: _args.listUuid,
      imageName: _imageName,
    );
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    clearPopupFields();
  }

  StorageReference getStorageRef() {
    _imageName = path.basename(pickedImage.path);
    return _imageService.uploadFile(_args.listUuid, pickedImage);
  }

  StorageUploadTask uploadItemPicture(StorageReference storageReference) {
    return storageReference.putFile(pickedImage);
  }

  void handleSubmittedItemCount(int input) {
    _count = input;
  }

  void handleSubmittedItemName(String input) {
    _name = input;
  }

  void incrementCounter() {
    _analytics.sendAnalyticsEvent("increment_counter_quantity");
    _count = _count + 1;
    itemCountController.text = (_count).toString();
  }

  void decrementCounter() {
    if (_count > 0) {
      _analytics.sendAnalyticsEvent("decrement_counter_quantity");
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

    imageType = "Scanned";
  }

  goToPreviousPage() {
    Navigator.of(context).pop();
  }
}
