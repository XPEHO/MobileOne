import 'dart:math';

import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gallery_saver/gallery_saver.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  final _imageService = GetIt.I.get<ImageService>();
  final _prefService = GetIt.I.get<PreferencesService>();
  final _userService = GetIt.I.get<UserService>();
  Widget _currentScreen = Lists();

  List _actions = [];

  Widget _floatingButtonIcon;
  Function _floatingButtonAction;

  final PageStorageBucket _bucket = PageStorageBucket();
  bool isOnlyOneStep = false;

  @override
  void initState() {
    GetIt.I.get<UserPictureProvider>().selectedPicturePath = GetIt.I
        .get<PreferencesService>()
        .getString('picture' + GetIt.I.get<UserService>().user.uid);
    super.initState();
    _actions = [
      scanLoyaltyCardsBareCode,
      goToCreateListPage,
      goToSharedPage,
      _getImage,
    ];

    _floatingButtonIcon = Icon(Icons.add);
    _floatingButtonAction = _actions[LISTS_PAGE];
  }

  Future<void> askPermissions() async {
    PermissionStatus permissionStatus = await _getContactPermission();

    if (permissionStatus != PermissionStatus.granted) {
      goToSharePage();
    } else {
      goToShareOnePage();
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.contacts);
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.restricted) {
      Map<PermissionGroup, PermissionStatus> permissionStatus =
          await PermissionHandler()
              .requestPermissions([PermissionGroup.contacts]);
      return permissionStatus[PermissionGroup.contacts] ??
          PermissionStatus.unknown;
    } else {
      return permission;
    }
  }

  _savePicturePreferences(String _picture, FirebaseUser user) async {
    _prefService.setString('picture' + user.uid, _picture);
  }

  Future _getImage() async {
    // Pick picture
    final pickedFile = await _imageService.pickCamera();

    if (pickedFile != null) {
      // Save picture path into Provider
      GetIt.I.get<UserPictureProvider>().selectedPicturePath = pickedFile.path;

      // Save image into phone gallery
      GallerySaver.saveImage(
        pickedFile.path,
        albumName: getString(context, "app_name"),
      );

      // Save select picture path to shared preferences
      _savePicturePreferences(pickedFile.path, _userService.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: GetIt.I.get<UserPictureProvider>(),
        child: Consumer<UserPictureProvider>(
          builder: (context, provider, _) => Scaffold(
            body: PageStorage(bucket: _bucket, child: _currentScreen),
            floatingActionButton: FloatingActionButton(
                key: Key("floating_button"),
                child: _floatingButtonIcon,
                backgroundColor: Colors.deepOrange,
                onPressed: () {
                  _floatingButtonAction();
                }),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              shape: CircularNotchedRectangle(),
              child: Container(
                height: 60,
                child: BottomBar(onBottomBarIndexSelected),
              ),
            ),
          ),
        ));
  }

  onBottomBarIndexSelected(index) {
    setState(() {
      _floatingButtonAction = _actions[index];
      switch (index) {
        case CARD_PAGE:
          _floatingButtonIcon = SvgPicture.asset("assets/images/qr-code.svg",
              color: WHITE, width: 24, height: 24);
          _currentScreen = LoyaltyCards();
          break;
        case LISTS_PAGE:
          _floatingButtonIcon = Icon(Icons.add);
          _currentScreen = Lists();
          break;
        case SHARE_PAGE:
          _floatingButtonIcon = Icon(Icons.share);
          _currentScreen = Share();
          break;
        case PROFILE_PAGE:
          _floatingButtonIcon = Icon(Icons.camera);
          _currentScreen = Profile();
          break;
      }
    });
  }

  unasignedAction() {
    debugPrint("no action assigned");
  }

  goToCreateListPage() {
    Navigator.of(context).pushNamed("/createList");
  }

  goToSharedPage() async {
    await askPermissions();
  }

  goToShareOnePage() {
    isOnlyOneStep = false;
    Navigator.of(context).pushNamed("/shareOne",
        arguments: ShareArguments(
          isOnlyOneStep: isOnlyOneStep,
        ));
  }

  goToSharePage() {
    Navigator.popUntil(context, ModalRoute.withName('/mainpage'));
  }

  scanLoyaltyCardsBareCode() async {
    var resultCard = await BarcodeScanner.scan();
    if (resultCard.type == ResultType.Barcode) {
      var labelCard = "";
      var colorCard = generateRandomHexColor();
      GetIt.I.get<LoyaltyCardsProvider>().addLoyaltyCardsToDataBase(
            labelCard,
            resultCard.rawContent,
            resultCard.format,
            colorCard,
          );
    }
  }

  String generateRandomHexColor() {
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while (length-- > 0) hex += chars[(Random().nextInt(16)) | 0];
    return hex;
  }
}
