import 'dart:convert';
import 'package:MobileOne/data/unit.dart';
import 'package:MobileOne/providers/wishlist_item_provider.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/widgets/quantity.dart';
import 'package:MobileOne/widgets/widget_icon_text_button.dart';
import 'package:MobileOne/widgets/widget_voice_record.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/arguments/arguments.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'dart:io';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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

  // services
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _imageService = GetIt.I.get<ImageService>();
  var _colorsApp = GetIt.I.get<ColorService>();

  ItemArguments _args;
  PickedFile _pickedImage;

  bool isInitialized = false;
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnItemsPage");
    itemCountController.text = "1";
    super.initState();
    _itemNameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _args = Arguments.value(context);
    return ChangeNotifierProvider.value(
      value: WishlistItemProvider(_args.listUuid, _args.itemUuid),
      child: Consumer<WishlistItemProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: buildAppBar(provider),
            backgroundColor: _colorsApp.colorTheme,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildImageAndButtons(context, provider),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: buildTextField(context, provider),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Quantity(
                        provider,
                        _itemQuantityFocusNode,
                        itemCountController,
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildUnit(context, provider),
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  AppBar buildAppBar(WishlistItemProvider provider) {
    return AppBar(
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
            _onValidate(provider);
          },
        ),
      ],
    );
  }

  Widget buildImageAndButtons(
      BuildContext context, WishlistItemProvider provider) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                if (provider.imageUrl != null) {
                  openBigImage(provider);
                }
              },
              child: Container(
                height: 76.0,
                color: WHITE,
                child: _pickedImage != null
                    ? Image.file(File(_pickedImage.path))
                    : provider.imageUrl != null
                        ? Image.network(provider.imageUrl)
                        : Icon(Icons.photo_outlined),
              ),
            ),
          ),
          IconTextButton(
            iconData: Icons.mic,
            onPressed: () => recordAudio(provider),
            backgroundColor: Colors.lime[600],
            text: "Label",
          ),
          IconTextButton(
            iconAsset: "assets/images/qr-code.svg",
            onPressed: () => scanAnItem(provider),
            backgroundColor: _colorsApp.buttonColor,
            text: "Scan",
          ),
          IconTextButton(
            key: Key("item_picture_button"),
            iconData: Icons.camera_alt_outlined,
            onPressed: () => pickImage(provider),
            backgroundColor: Colors.teal,
            text: "Photo",
          ),
        ],
      ),
    );
  }

  Widget buildUnit(BuildContext context, WishlistItemProvider provider) {
    final items = <String>[
      getString(context, 'item_unit'),
      getString(context, 'item_liters'),
      getString(context, 'item_grams'),
      getString(context, 'item_kilos')
    ];

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TRANSPARENT),
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        filled: true,
        fillColor: _colorsApp.greyColor,
      ),
      hint: Text(
        getString(context, 'item_type'),
      ),
      onChanged: (text) {
        setState(() {
          provider.unit = toUnitId(context, text);
        });
      },
      value: toStringUnit(context, provider.unit),
      items: items.map((String value) {
        return new DropdownMenuItem<String>(
          value: value,
          child: new Text(value, style: TextStyle(color: GREY, fontSize: 13)),
        );
      }).toList(),
    );
  }

  Widget buildTextField(BuildContext context, WishlistItemProvider provider) {
    itemNameController.text = provider.label;
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
          borderRadius: BorderRadius.circular(0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.lime[600],
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(0.0),
        ),
        filled: true,
        fillColor: Colors.grey[300],
      ),
      controller: itemNameController,
      onChanged: (text) => provider.label = text,
    );
  }

  Future<void> openBigImage(WishlistItemProvider provider) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Image.network(provider.imageUrl),
          ),
        );
      },
    );
  }

  recordAudio(WishlistItemProvider provider) async {
    isInitialized = await speech.initialize();
    if (isInitialized) {
      String result = await buildRecordPopup();
      speech.cancel();
      speech.stop();
      provider.audioLabel = result;
    } else {
      Fluttertoast.showToast(msg: getString(context, 'microphone_access'));
    }
  }

  Future<String> buildRecordPopup() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return WidgetVoiceRecord(speech: speech);
        });
  }

  Future<void> pickImage(WishlistItemProvider provider) async {
    _analytics.sendAnalyticsEvent("takePictureOfItem");

    await _imageService.pickCamera(30, 720, 720).then((image) {
      if (image != null && image.path != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    });
  }

  _onValidate(WishlistItemProvider provider) async {
    if (!provider.canValidate()) {
      Fluttertoast.showToast(msg: getString(context, "popup_alert"));
    } else {
      waitForImageUpload(provider);
    }
  }

  void waitForImageUpload(WishlistItemProvider provider) async {
    if (_pickedImage != null) {
      StorageReference ref = getStorageRef(provider);
      StorageUploadTask uploadTask = uploadItemPicture(ref);
      await uploadTask.onComplete;
      var fileURL = await ref.getDownloadURL();
      provider.imageUrl = fileURL;
    }

    bool update = provider.itemUuid != null;
    if (update) {
      updapteItemInList(provider);
    } else {
      addItemToList(provider);
    }
  }

  void updapteItemInList(WishlistItemProvider provider) async {
    _analytics.sendAnalyticsEvent("update_item");

    provider.updateItemInList();

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(true);
  }

  void addItemToList(WishlistItemProvider provider) async {
    _analytics.sendAnalyticsEvent("add_item");

    await provider.addItemTolist();

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(true);
  }

  StorageReference getStorageRef(WishlistItemProvider provider) {
    if (provider.imageName != null) {
      _imageService.deleteFile(_args.listUuid, provider.imageName);
    }
    provider.imageName = path.basename(_pickedImage.path);
    return _imageService.uploadFile(_args.listUuid, File(_pickedImage.path));
  }

  StorageUploadTask uploadItemPicture(StorageReference storageReference) {
    return storageReference.putFile(File(_pickedImage.path));
  }

  Future<void> scanAnItem(WishlistItemProvider provider) async {
    var result = await BarcodeScanner.scan();

    var response = await http.get(
        "https://world.openfoodfacts.org/api/v0/product/" +
            result.rawContent +
            ".json");
    Map<String, dynamic> article = jsonDecode(response.body);
    if (article["product"] != null) {
      String productName = article["product"]["product_name"].toString() ?? "";
      String brand = article["product"]["brands"].toString() ?? "";
      String itemLabel = "$productName - $brand";
      provider.scanLabel = itemLabel;
      provider.imageUrl = article["product"]["image_url"];
    } else {
      Fluttertoast.showToast(msg: getString(context, "cant_find_article"));
    }
  }

  goToPreviousPage() {
    Navigator.of(context).pop(false);
  }
}
