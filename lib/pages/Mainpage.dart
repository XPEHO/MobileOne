import 'dart:math';

import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/pages/loyaltycards_page.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:MobileOne/providers/wishlistsList_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
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
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

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
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  var bottomBackground;

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
      createList,
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
    _analytics.sendAnalyticsEvent("change_picture_from_camera");
    // Pick picture
    final pickedFile = await _imageService.pickCamera(100, 1080, 1080);

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
          appBar: AppBar(
            backgroundColor: _colorsApp.colorTheme,
            title: (_floatingButtonAction == goToSharedPage)
                ? Center(child: Text(getString(context, "my_shares")))
                : Text(""),
          ),
          backgroundColor: bottomBackground,
          body: PageStorage(bucket: _bucket, child: _currentScreen),
          floatingActionButton: FloatingActionButton(
              key: Key("floating_button"),
              child: _floatingButtonIcon,
              backgroundColor: _colorsApp.buttonColor,
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
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    children: [
                      Text(getString(context, "app_name")),
                      Image.asset(
                        "assets/images/square-logo.png",
                        width: 100,
                        height: 100,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: _colorsApp.buttonColor,
                  ),
                ),
                ListTile(
                  title: Text(getString(context, "feedback_text")),
                  onTap: () {
                    sendFeedback();
                  },
                ),
                ListTile(
                  title: Text(getString(context, "about") +
                      getString(context, "app_name")),
                  onTap: () {
                    aboutScreen();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  sendFeedback() async {
    final _controller = TextEditingController();
    Navigator.pop(context);
    final Email email = Email(
      body: _controller.text,
      subject: getString(context, 'feedback'),
      recipients: ['xpeho.mobile@gmail.com'],
    );

    await FlutterEmailSender.send(email);
  }

  void aboutScreen() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
              title: Text(
                  getString(context, "about") + getString(context, "app_name")),
              actions: [
                FlatButton(
                  child: Text('CANCEL'),
                  onPressed: Navigator.of(context).pop,
                ),
              ],
              content: aboutApp());
        });
  }

  aboutApp() {
    String version;
    return Wrap(
      children: [
        Text(
          getString(context, "name_of_app") + getString(context, "app_name"),
        ),
        FutureBuilder(
          future: rootBundle.loadString("pubspec.yaml"),
          builder: (context, snapshot) {
            version = "Unknown";
            if (snapshot.hasData) {
              var yaml = loadYaml(snapshot.data);
              version = yaml["version"];
            }

            return Container(
              child: Text(
                  getString(context, "version") + '${version.split("+")[0]}'),
            );
          },
        ),
        Text(
          getString(context, "company") + getString(context, "company_name"),
        ),
        Text(
          getString(context, "website") + getString(context, "xpeho_website"),
        ),
      ],
    );
  }

  onBottomBarIndexSelected(index) {
    setState(() {
      _floatingButtonAction = _actions[index];
      switch (index) {
        case CARD_PAGE:
          _floatingButtonIcon = SvgPicture.asset("assets/images/qr-code.svg",
              color: WHITE, width: 24, height: 24);
          _currentScreen = LoyaltyCards();
          bottomBackground = _colorsApp.colorTheme;
          break;
        case LISTS_PAGE:
          _floatingButtonIcon = Icon(Icons.add);
          _currentScreen = Lists();
          bottomBackground = _colorsApp.colorTheme;
          break;
        case SHARE_PAGE:
          _floatingButtonIcon = Icon(Icons.share);
          _currentScreen = Share();
          bottomBackground = _colorsApp.colorTheme;
          break;
        case PROFILE_PAGE:
          _floatingButtonIcon = Icon(Icons.camera);
          _currentScreen = Profile();
          bottomBackground = WHITE;
          break;
      }
    });
  }

  unasignedAction() {
    debugPrint("no action assigned");
  }

  createList() async {
    await GetIt.I.get<WishlistsListProvider>().addWishlist(context);
    _analytics.sendAnalyticsEvent("add_wishlist");
  }

  goToSharedPage() async {
    _analytics.sendAnalyticsEvent("share_list_from_button");
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
    Navigator.popUntil(context, ModalRoute.withName('/mainPage'));
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
    _analytics.sendAnalyticsEvent("add_loyalty_card");
  }

  String generateRandomHexColor() {
    int length = 6;
    String chars = '0123456789ABCDEF';
    String hex = '#';
    while (length-- > 0) hex += chars[(Random().nextInt(16)) | 0];
    return hex;
  }
}
