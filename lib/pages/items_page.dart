import 'dart:convert';
import 'package:MobileOne/providers/recipeItems_provider.dart';
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
  var _recipeItemsProvider = GetIt.I.get<RecipeItemsProvider>();
  String _name;
  int _count = 1;
  String _type;
  String imageLink;
  String _imageName;
  String _oldImageName;

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
  String _localeId;
  String _collection;

  Future<void> getItems() async {
    String labelValue;
    String quantityValue;
    String unitValue;

    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(_args.listUuid)
        .get()
        .then((value) {
      labelValue = value.data()[_args.itemUuid]["label"];
      quantityValue = value.data()[_args.itemUuid]["quantity"].toString();
      imageLink = value.data()[_args.itemUuid]["image"];
      if (value.data()[_args.itemUuid]["imageName"] != null) {
        _imageName = value.data()[_args.itemUuid]["imageName"];
      }
      if (imageLink != null) {
        _itemImage = Image(image: NetworkImage(imageLink));
      }
      switch (value.data()[_args.itemUuid]["unit"]) {
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
    _itemImage = Icon(
      Icons.photo_camera,
      size: 48,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => getData());
    super.initState();
    _itemNameFocusNode.requestFocus();
    initializeSpeech();
  }

  initializeSpeech() async {
    isInitialized = await speech.initialize();
    var systemLocale = await speech.systemLocale();
    _localeId = systemLocale.localeId;
  }

  void getData() {
    _args.isRecipe ? _collection = "recipeItems" : _collection = "items";
    if (_args.buttonName == getString(context, "popup_update")) {
      _analytics.sendAnalyticsEvent("update_item");
      getItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    _args = Arguments.value(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorsApp.colorTheme,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            goToPreviousPage();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
            ),
            onPressed: () {
              _onValidate();
            },
          ),
        ],
      ),
      backgroundColor: _colorsApp.colorTheme,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Container(
                child: buildImageAndButtons(context),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Container(child: Center(child: buildTextField(context))),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: buildDecrementCounter(),
                    ),
                    Flexible(
                      flex: 2,
                      child: buildQuantityText(),
                    ),
                    Flexible(
                      flex: 1,
                      child: buildIncrementCounter(context),
                    ),
                    Flexible(
                      flex: 2,
                      child: buildUnit(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildImageAndButtons(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: InkWell(
            onTap: () {
              if (_itemImage is Image) {
                openBigImage();
              }
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: WHITE,
              child: _itemImage,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    color: Colors.lime[600],
                    child: IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: WHITE,
                        size: 24,
                      ),
                      onPressed: () => recordAudio(),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    color: _colorsApp.buttonColor,
                    child: IconButton(
                      icon: SvgPicture.asset(
                        "assets/images/qr-code.svg",
                        color: WHITE,
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () => scanAnItem(),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    color: Colors.teal,
                    child: IconButton(
                      key: Key("item_picture_button"),
                      icon: Icon(
                        Icons.camera,
                        color: WHITE,
                        size: 24,
                      ),
                      onPressed: () {
                        _analytics.sendAnalyticsEvent("takePictureOfItem");
                        pickImage();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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

    return Container(
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
            child: new Text(value, style: TextStyle(color: GREY, fontSize: 13)),
          );
        }).toList(),
      ),
    );
  }

  Widget buildDecrementCounter() {
    return BubbleButton(
      icon: Icon(Icons.remove, color: WHITE),
      color: Colors.lime[600],
      onPressed: () => decrementCounter(),
    );
  }

  Widget buildQuantityText() {
    return TextField(
      focusNode: _itemQuantityFocusNode,
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
    );
  }

  Widget buildIncrementCounter(BuildContext context) {
    return BubbleButton(
      icon: Icon(Icons.add, color: WHITE),
      color: Colors.lime[600],
      onPressed: () => incrementCounter(),
    );
  }

  Widget buildTextField(BuildContext context) {
    return TextField(
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
    );
  }

  Future<void> openBigImage() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: _itemImage,
          ),
        );
      },
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
      localeId: _localeId,
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
        .pickCamera(30, 720, 720)
        .then((image) => pickedImage = File(image.path));

    setState(() {
      _itemImage = Image(
        image: FileImage(pickedImage),
        fit: BoxFit.cover,
      );
    });

    imageType = "Picked";
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
      Fluttertoast.showToast(msg: getString(context, "popup_alert"));
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

    _args.isRecipe
        ? await _recipeItemsProvider.updateItemInRecipe(
            itemUuid: _args.itemUuid,
            name: _name,
            count: _count,
            typeIndex: _typeIndex,
            imageLink: imageLink,
            recipeUuid: _args.listUuid,
            imageName: _imageName,
          )
        : await _itemsListProvider.updateItemInList(
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

    _args.isRecipe
        ? await _recipeItemsProvider.addItemToRecipe(
            name: _name,
            count: _count,
            typeIndex: _typeIndex,
            imageLink: imageLink,
            recipeUuid: _args.listUuid,
            imageName: _imageName,
          )
        : await _itemsListProvider.addItemTolist(
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
      imageLink = article["product"]["image_url"];
      setState(() {
        _itemImage = Image(
          image: NetworkImage(imageLink),
          fit: BoxFit.cover,
        );
      });
    } else {
      Fluttertoast.showToast(msg: getString(context, "cant_find_article"));
    }

    imageType = "Scanned";
  }

  goToPreviousPage() {
    Navigator.of(context).pop();
  }
}
