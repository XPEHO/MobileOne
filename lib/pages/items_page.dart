import 'dart:convert';
import 'package:MobileOne/data/unit.dart';
import 'package:MobileOne/providers/wishlist_item_provider.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/tutorial_service.dart';
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
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  final _wishlistsListProvider = GetIt.I.get<WishlistsListProvider>();
  final _tutorialService = GetIt.I.get<TutorialService>();

  ItemArguments _args;
  PickedFile _pickedImage;

  bool isInitialized = false;
  final SpeechToText speech = SpeechToText();

  List<TargetFocus> targets = List();
  GlobalKey tutorialKey = GlobalKey(debugLabel: "Item image");
  GlobalKey tutorialKey1 = GlobalKey(debugLabel: "Voice record");
  GlobalKey tutorialKey2 = GlobalKey(debugLabel: "Barcode scan");
  GlobalKey tutorialKey3 = GlobalKey(debugLabel: "Take picture");
  GlobalKey tutorialKey4 = GlobalKey(debugLabel: "Label");
  GlobalKey tutorialKey5 = GlobalKey(debugLabel: "Quantity");
  GlobalKey tutorialKey6 = GlobalKey(debugLabel: "Unit");
  GlobalKey tutorialKey7 = GlobalKey(debugLabel: "Validate");

  @override
  void initState() {
    _analytics.setCurrentPage("isOnItemsPage");
    itemCountController.text = "1";
    super.initState();
    _itemNameFocusNode.requestFocus();
  }

  void initTargets() {
    targets.add(
      _tutorialService.createTarget(
        identifier: "Item image",
        key: tutorialKey,
        title: getString(context, "tutorial_item_image_title"),
        text: getString(context, "tutorial_item_image_text"),
        positionTop: 300,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Voice record",
        key: tutorialKey1,
        title: getString(context, "tutorial_voice_record_title"),
        text: getString(context, "tutorial_voice_record_text"),
        positionTop: 200,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Barcode scan",
        key: tutorialKey2,
        title: getString(context, "tutorial_barcode_scan_title"),
        text: getString(context, "tutorial_barcode_scan_text"),
        positionTop: 200,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Take picture",
        key: tutorialKey3,
        title: getString(context, "tutorial_take_item_picture_title"),
        text: getString(context, "tutorial_take_item_picture_text"),
        positionTop: 200,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Label",
        key: tutorialKey4,
        title: getString(context, "tutorial_label_title"),
        text: getString(context, "tutorial_label_text"),
        positionBottom: 30,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Quantity",
        key: tutorialKey5,
        title: getString(context, "tutorial_quantity_title"),
        text: getString(context, "tutorial_quantity_text"),
        positionTop: 150,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Unit",
        key: tutorialKey6,
        title: getString(context, "tutorial_unit_title"),
        text: getString(context, "tutorial_unit_text"),
        positionTop: 200,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Validate",
        key: tutorialKey7,
        title: getString(context, "tutorial_validate_title"),
        text: getString(context, "tutorial_validate_text"),
        positionTop: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initTargets();
    _args = Arguments.value(context);
    GetIt.I
        .get<WishlistItemProvider>()
        .fetchItem(_args.listUuid, _args.itemUuid);
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<WishlistItemProvider>(),
      child: Consumer<WishlistItemProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: buildAppBar(provider, _args),
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
                      key: tutorialKey5,
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

  AppBar buildAppBar(WishlistItemProvider provider, ItemArguments _args) {
    return AppBar(
      backgroundColor: _colorsApp.colorTheme,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () {
          goToPreviousPage(provider);
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.help,
          ),
          onPressed: () {
            _tutorialService.showTutorial(targets, context);
          },
        ),
        IconButton(
          key: tutorialKey7,
          icon: Icon(
            Icons.check,
          ),
          onPressed: () {
            _onValidate(provider, _args);
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
              key: tutorialKey,
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
            key: tutorialKey1,
            iconData: Icons.mic,
            onPressed: () => recordAudio(provider),
            backgroundColor: Colors.lime[600],
            text: "Label",
          ),
          IconTextButton(
            key: tutorialKey2,
            iconAsset: "assets/images/qr-code.svg",
            onPressed: () => scanAnItem(provider),
            backgroundColor: _colorsApp.buttonColor,
            text: "Scan",
          ),
          IconTextButton(
            key: tutorialKey3,
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
      getString(context, 'item_kilos'),
      getString(context, "item_packs"),
      getString(context, "item_boxes"),
      getString(context, "item_bottles"),
      getString(context, "item_cans"),
      getString(context, "item_cartons"),
    ];

    return DropdownButtonFormField<String>(
      key: tutorialKey6,
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
      key: tutorialKey4,
      focusNode: _itemNameFocusNode,
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

  _onValidate(WishlistItemProvider provider, ItemArguments _args) async {
    if (!provider.canValidate()) {
      Fluttertoast.showToast(msg: getString(context, "popup_alert"));
    } else {
      waitForImageUpload(provider, _args);
    }
  }

  void waitForImageUpload(
      WishlistItemProvider provider, ItemArguments _args) async {
    if (_pickedImage != null) {
      StorageReference ref = getStorageRef(provider);
      StorageUploadTask uploadTask = uploadItemPicture(ref);
      await uploadTask.onComplete;
      var fileURL = await ref.getDownloadURL();
      provider.imageUrl = fileURL;
    }

    bool update = _args.itemUuid != null;
    if (update) {
      updapteItemInList(provider, _args);
    } else {
      addItemToList(provider, _args);
    }
  }

  void updapteItemInList(
      WishlistItemProvider provider, ItemArguments _args) async {
    _analytics.sendAnalyticsEvent("update_item");

    provider.updateItemInList(_args.listUuid, _args.itemUuid);

    _wishlistsListProvider.setWishlistModificationTime(_args.listUuid);

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(true);
  }

  void addItemToList(WishlistItemProvider provider, ItemArguments _args) async {
    _analytics.sendAnalyticsEvent("add_item");

    await provider.addItemTolist(_args.listUuid);

    _wishlistsListProvider.setWishlistModificationTime(_args.listUuid);

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

  goToPreviousPage(WishlistItemProvider provider) {
    provider.uninitialise();
    Navigator.of(context).pop(false);
  }
}
