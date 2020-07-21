import 'dart:math';

import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  var userService = GetIt.I.get<UserService>();
  Widget _currentScreen = Lists();
  final List _centerIcons = [
    Icons.scanner,
    Icons.add,
    Icons.share,
    Icons.camera,
  ];

  List _actions = [];

  IconData _floatingButtonIcon;
  Function _floatingButtonAction;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _actions = [
      scanLoyaltyCardsBareCode,
      goToCreateListPage,
      goToSharedPage,
      unasignedAction,
    ];

    _floatingButtonIcon = _centerIcons[LISTS_PAGE];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _currentScreen),
      floatingActionButton: FloatingActionButton(
        child: Icon(_floatingButtonIcon),
        backgroundColor: Colors.deepOrange,
        onPressed: () => _floatingButtonAction(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: BottomBar(onBottomBarIndexSelected),
        ),
      ),
    );
  }

  onBottomBarIndexSelected(index) {
    setState(() {
      _floatingButtonIcon = _centerIcons[index];
      _floatingButtonAction = _actions[index];
      switch (index) {
        case CARD_PAGE:
          _currentScreen = LoyaltyCards();
          break;
        case LISTS_PAGE:
          _currentScreen = Lists();
          break;
        case SHARE_PAGE:
          _currentScreen = Share();
          break;
        case PROFILE_PAGE:
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
    Navigator.of(context).pushNamed("/shareOne");
  }

  goToSharePage() {
    Navigator.popUntil(context, ModalRoute.withName('/mainpage'));
  }

  scanLoyaltyCardsBareCode() async {
    var resultCard = await BarcodeScanner.scan();
    var labelCard = "";
    var colorCard = generateRandomHexColor();
    GetIt.I.get<LoyaltyCardsProvider>().addLoyaltyCardsToDataBase(
          labelCard,
          resultCard.rawContent,
          colorCard,
        );
  }

  String generateRandomHexColor() {
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while (length-- > 0) hex += chars[(Random().nextInt(16)) | 0];
    return hex;
  }
}
