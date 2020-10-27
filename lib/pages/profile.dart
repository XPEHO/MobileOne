import 'dart:io';
import 'package:MobileOne/data/user_picture.dart';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/change_password.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/recipes_service.dart';
import 'package:MobileOne/services/tutorial_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/services/wishlist_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/text_icon.dart';
import 'package:MobileOne/widgets/widget_custom_drawer.dart';
import 'package:MobileOne/widgets/widget_deletion_confirmation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const KEY_GALLERY = "Gallery";
const KEY_PASSWORD = "Password";
const KEY_DELETE_ACCOUNT = "debug_delete_account_button";

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final _userService = GetIt.I.get<UserService>();
  final _imageService = GetIt.I.get<ImageService>();
  final _prefService = GetIt.I.get<PreferencesService>();
  final _auth = GetIt.I.get<FirebaseAuth>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  final _wishlistService = GetIt.I.get<WishlistService>();
  final _recipesService = GetIt.I.get<RecipesService>();
  final _pictureProvider = GetIt.I.get<UserPictureProvider>();
  final _tutorialService = GetIt.I.get<TutorialService>();

  List<TargetFocus> targets = List();
  GlobalKey tutorialKey = GlobalKey(debugLabel: "Use gallery");
  GlobalKey tutorialKey1 = GlobalKey(debugLabel: "Settings");
  GlobalKey tutorialKey2 = GlobalKey(debugLabel: "Change password");
  GlobalKey tutorialKey3 = GlobalKey(debugLabel: "Disconnect");
  GlobalKey tutorialKey4 = GlobalKey(debugLabel: "Delete account");

  @override
  initState() {
    _analytics.setCurrentPage("isOnProfilePage");
    super.initState();
  }

  void initTargets() {
    targets.add(
      _tutorialService.createTarget(
        identifier: "Take picture",
        position: TargetPosition(
            Size(40, 40),
            Offset(
              (MediaQuery.of(context).size.width / 2) - 20,
              MediaQuery.of(context).size.height - 80,
            )),
        title: getString(context, "tutorial_take_picture_title"),
        text: getString(context, "tutorial_take_picture_text"),
        positionBottom: 200,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Use gallery",
        key: tutorialKey,
        title: getString(context, "tutorial_use_gallery_title"),
        text: getString(context, "tutorial_use_gallery_text"),
        positionTop: 300,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Settings",
        key: tutorialKey1,
        title: getString(context, "tutorial_settings_title"),
        text: getString(context, "tutorial_settings_text"),
        positionTop: 20,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Change password",
        key: tutorialKey2,
        title: getString(context, "tutorial_change_password_title"),
        text: getString(context, "tutorial_change_password_text"),
        positionTop: 40,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Disconnect",
        key: tutorialKey3,
        title: getString(context, "tutorial_disconnect_title"),
        text: getString(context, "tutorial_disconnect_text"),
        positionTop: 80,
      ),
    );
    targets.add(
      _tutorialService.createTarget(
        identifier: "Delete account",
        key: tutorialKey4,
        title: getString(context, "tutorial_delete_account_title"),
        text: getString(context, "tutorial_delete_account_text"),
        positionTop: 100,
      ),
    );
  }

  Widget build(BuildContext context) {
    initTargets();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorsApp.colorTheme,
      ),
      drawer: CustomDrawer(
        context: context,
        targets: targets,
      ),
      body: buildContent(context, _auth.currentUser),
    );
  }

  Widget buildContent(BuildContext context, User user) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            color: _colorsApp.colorTheme,
            height: MediaQuery.of(context).size.height * 0.25,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                    child: Container(
                  child: _buildProfilePicture(user),
                )),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            user?.displayName != null
                                ? user.displayName
                                : user?.email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: WHITE,
                            ),
                          ),
                        ),
                      ),
                      user?.displayName != null
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                              width: MediaQuery.of(context).size.width,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: WHITE,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          (_userService.user.emailVerified == false)
              ? Container(
                  color: RED,
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      getString(context, "email_not_valid"),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: WHITE),
                    ),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: InkWell(
              key: tutorialKey1,
              onTap: goToSettingsPage,
              child: RectangleTextIcon(
                getString(context, "settings"),
                Icons.arrow_forward_ios,
                GREY,
              ),
            ),
          ),
          (_isPasswordUser())
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    key: tutorialKey2,
                    onTap: goToChangePasswordPage,
                    child: RectangleTextIcon(
                      getString(context, "change_user_password"),
                      Icons.arrow_forward_ios,
                      GREY,
                    ),
                  ),
                )
              : Container(),
          (_isPasswordUser())
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    key: tutorialKey3,
                    onTap: () {
                      signout(user);
                    },
                    child: RectangleTextIcon(
                      getString(context, 'sign out'),
                      Icons.exit_to_app,
                      GREY,
                    ),
                  ),
                )
              : Container(),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                getString(context, "zone"),
                style: TextStyle(
                    color: RED, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          (_isPasswordUser())
              ? Container(
                  key: Key(KEY_DELETE_ACCOUNT),
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    key: tutorialKey4,
                    onTap: () {
                      checkAccount(user);
                    },
                    child: RectangleTextIcon(
                      getString(context, 'debug_delete_account_button'),
                      Icons.delete_forever,
                      RED,
                    ),
                  ),
                )
              : Container(),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
        ],
      ),
    );
  }

  Future<void> checkAccount(User user) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeletionConfirmationPopupWidget();
      },
    );
  }

  Widget _buildProfilePicture(User user) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<UserPictureProvider>(),
      child: Consumer<UserPictureProvider>(
        builder: (context, provider, _) {
          CircleAvatar circlePicture;
          UserPicture userPicture = _pictureProvider.getUserPicture();

          if (userPicture != null &&
              userPicture.path != null &&
              userPicture.path.isNotEmpty) {
            circlePicture = CircleAvatar(
              backgroundColor: WHITE,
              backgroundImage: NetworkImage(
                userPicture.path,
              ),
              radius: 30.0,
            );
          } else {
            if (user.photoURL != null && user.photoURL.isNotEmpty) {
              circlePicture = CircleAvatar(
                backgroundColor: WHITE,
                backgroundImage: NetworkImage(
                  user.photoURL,
                ),
                radius: 30.0,
              );
            } else {
              circlePicture = CircleAvatar(
                backgroundColor: WHITE,
                child: Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 30,
                ),
                radius: 30.0,
              );
            }
          }
          return GestureDetector(
            key: tutorialKey,
            onTap: () => _selectPicture(provider),
            child: circlePicture,
          );
        },
      ),
    );
  }

  Future _selectPicture(provider) async {
    final pickedFile = await _imageService.pickGallery();
    if (pickedFile != null) {
      _analytics.sendAnalyticsEvent("uploadPictureFromGallery");
      _pictureProvider.deleteUserPicture();
      StorageReference ref =
          _pictureProvider.getStorageRef(File(pickedFile.path));
      StorageUploadTask uploadTask =
          _pictureProvider.uploadItemPicture(ref, File(pickedFile.path));
      uploadTask.onComplete.then((_) {
        ref.getDownloadURL().then((fileURL) {
          _pictureProvider.setUserPicture(fileURL);
        });
      });
    }
  }

  bool _isPasswordUser() {
    final user = _userService.user;
    final passwordProvider =
        user.providerData.any((provider) => provider.providerId == "password");
    return passwordProvider != null;
  }

  void openAuthenticationPage() {
    _prefService.sharedPreferences.remove("email");
    _prefService.sharedPreferences.remove("password");
    _prefService.sharedPreferences.remove("mode");
    _wishlistService.flushWishlists();
    _recipesService.flushRecipes();
    _pictureProvider.flushPicture();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/authentication', (Route<dynamic> route) => false);
    _userService.user = null;
    _analytics.sendAnalyticsEvent("logout");
  }

  signout(User user) {
    if (user != null) {
      try {
        openAuthenticationPage();
        _userService.user = null;
      } catch (e) {
        debugPrint(e);
      }
    } else {
      Fluttertoast.showToast(
        msg: getString(context, 'no_user'),
      );
    }
  }

  goToSettingsPage() {
    Navigator.of(context).pushNamed('/settings');
  }

  goToChangePasswordPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangePassword(),
      ),
    );
  }
}
