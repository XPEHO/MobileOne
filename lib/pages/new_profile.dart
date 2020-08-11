import 'dart:io';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/change_password.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/image_service.dart';
import 'package:MobileOne/services/preferences_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/text_icon.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

const KEY_GALLERY = "Gallery";
const KEY_PASSWORD = "Password";
const KEY_DELETE_ACCOUNT = "debug_delete_account_button";

class NewProfile extends StatefulWidget {
  NewProfileState createState() => NewProfileState();
}

class NewProfileState extends State<NewProfile> {
  final _userService = GetIt.I.get<UserService>();
  final _imageService = GetIt.I.get<ImageService>();
  final _prefService = GetIt.I.get<PreferencesService>();
  var _authService = GetIt.I.get<AuthenticationService>();
  final _auth = GetIt.I.get<FirebaseAuth>();
  var _analytics = GetIt.I.get<AnalyticsService>();
  @override
  initState() {
    _analytics.setCurrentPage("isOnProfilePage");
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _auth.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildContent(context, snapshot.data);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget buildContent(BuildContext context, FirebaseUser user) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            color: CYAN,
            height: MediaQuery.of(context).size.height * 0.3,
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
                            user.displayName != null
                                ? user.displayName
                                : user.email,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: WHITE,
                            ),
                          ),
                        ),
                      ),
                      Container(
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          (_userService.user.isEmailVerified == false)
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
          (_isPasswordUser())
              ? Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width,
                  child: InkWell(
                    key: Key(KEY_PASSWORD),
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
                    onTap: () {
                      confirmAccountDeletion().then((value) async {
                        if (value == true) {
                          reconnectUser(user);
                        }
                      });
                    },
                    child: RectangleTextIcon(
                      getString(context, 'debug_delete_account_button'),
                      Icons.delete_forever,
                      RED,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Future<bool> confirmAccountDeletion() async {
    bool result = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(getString(context, 'confirm_account_deletion')),
          actions: <Widget>[
            FlatButton(
                key: Key("confirmAccountDeletion"),
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
                child: Text(getString(context, 'delete_account'))),
            FlatButton(
              key: Key("cancelAccountDeletion"),
              onPressed: () {
                result = false;
                Navigator.of(context).pop();
              },
              child: Text(getString(context, 'cancel_deletion')),
            ),
          ],
        );
      },
    );
    return result;
  }

  Widget _buildProfilePicture(FirebaseUser user) {
    _analytics.sendAnalyticsEvent("change_picture_from_gallery");
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<UserPictureProvider>(),
      child: Consumer<UserPictureProvider>(
        builder: (context, provider, _) {
          CircleAvatar userPicture;

          String selectedPicturePath = provider.selectedPicturePath;
          if (selectedPicturePath != null) {
            userPicture = CircleAvatar(
              backgroundColor: WHITE,
              backgroundImage: FileImage(
                File(selectedPicturePath),
              ),
              radius: 30.0,
            );
          } else {
            if (user.photoUrl != null && user.photoUrl.isNotEmpty) {
              userPicture = CircleAvatar(
                backgroundColor: WHITE,
                backgroundImage: NetworkImage(
                  user.photoUrl,
                ),
                radius: 30.0,
              );
            } else {
              userPicture = CircleAvatar(
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
            key: Key(KEY_GALLERY),
            onTap: () => _selectPicture(provider),
            child: userPicture,
          );
        },
      ),
    );
  }

  Future _selectPicture(provider) async {
    final pickedFile = await _imageService.pickGallery();
    if (pickedFile != null) {
      provider.selectedPicturePath = pickedFile.path;
      _savePicturePreferencesGallery(pickedFile.path);
    }
  }

  _savePicturePreferencesGallery(String _picture) async {
    _prefService.setString("picture" + _userService.user.uid, _picture);
  }

  bool _isPasswordUser() {
    final user = _userService.user;
    final passwordProvider =
        user.providerData.any((provider) => provider.providerId == "password");
    return passwordProvider != null;
  }

  void openAuthenticationPage() {
    Navigator.popUntil(
      context,
      ModalRoute.withName('/'),
    );
    _userService.user = null;
    _analytics.sendAnalyticsEvent("logout");
  }

  reconnectUser(FirebaseUser user) async {
    String result = await _authService.reconnectUser(
        user, user.email, _prefService.getPassword());
    switch (result) {
      case "success":
        deleteAccount(user);
        break;
      case "ERROR_USER_DISABLED":
        Fluttertoast.showToast(msg: getString(context, 'user_disabled'));
        break;
      case "ERROR_USER_NOT_FOUND":
        Fluttertoast.showToast(msg: getString(context, 'user_not_found'));
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        Fluttertoast.showToast(msg: getString(context, 'changing_not_allowed'));
        break;
      case "ERROR_INVALID_CREDENTIAL":
        Fluttertoast.showToast(msg: getString(context, 'invalid_credential'));
        break;
      case "ERROR_WRONG_PASSWORD":
        Fluttertoast.showToast(msg: getString(context, 'wrong_password'));
        break;
      default:
        Fluttertoast.showToast(msg: getString(context, 'default_error'));
    }
  }

  deleteAccount(FirebaseUser user) async {
    String userUid = user.uid;
    await _userService.deleteUserData(userUid);
    String result = await _userService.deleteAccount(user);
    switch (result) {
      case "success":
        _prefService.sharedPreferences.remove("email");
        _prefService.sharedPreferences.remove("password");
        _prefService.sharedPreferences.remove("mode");
        Fluttertoast.showToast(
          msg: getString(context, 'debug_account_deleted'),
        );
        openAuthenticationPage();
        _userService.user = null;
        break;
      case "ERROR_REQUIRES_RECENT_LOGIN":
        Fluttertoast.showToast(msg: getString(context, 'recent_login_needed'));
        break;
      case "ERROR_INVALID_CREDENTIAL":
        Fluttertoast.showToast(msg: getString(context, 'invalid_credential'));
        break;
      case "ERROR_USER_DISABLED":
        Fluttertoast.showToast(msg: getString(context, 'user_disabled'));
        break;
      case "ERROR_USER_NOT_FOUND":
        Fluttertoast.showToast(msg: getString(context, 'user_not_found'));
        break;
      default:
        Fluttertoast.showToast(
          msg: getString(context, 'default_error'),
        );
    }
    _analytics.sendAnalyticsEvent("delete_account");
  }

  signout(FirebaseUser user) {
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

  goToChangePasswordPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangePassword(),
      ),
    );
  }
}
