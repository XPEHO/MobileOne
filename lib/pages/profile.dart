import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/change_password.dart';
import 'package:MobileOne/providers/user_picture_provider.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'dart:io';
import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double FONT_SIZE = 15;
const KEY_PASSWORD = "Password";
const KEY_DELETE_ACCOUNT = "debug_delete_account_button";

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  bool isInGallery = false;
  File imageGallery;
  var _authenticationService = GetIt.I.get<AuthenticationService>();

  final _auth = GetIt.I.get<FirebaseAuth>();
  final _picker = ImagePicker();

  _savePicturePreferencesGallery(String _picture, FirebaseUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('picture' + user.uid, _picture);
  }

  Future _selectPicture(provider) async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      isInGallery = true;
      provider.selectedPicturePath = pickedFile.path;
    }
    _savePicturePreferencesGallery(pickedFile.path, UserService().user);
  }

  Widget buildContent(BuildContext context, FirebaseUser user) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: 230.0,
            child: Stack(
              children: <Widget>[
                Material(
                  elevation: 8.0,
                  child: Container(
                    height: 200.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: new BoxDecoration(
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image:
                            new AssetImage("assets/images/profile_header.png"),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 24,
                  top: 180,
                  child: Material(
                    // key: Key("Gallery"),
                    borderRadius: BorderRadius.circular(24),
                    elevation: 8.0,
                    child: _buildProfilePicture(user),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0, top: 40.0, right: 5.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  side: BorderSide(color: const Color(0xFFBDBDBD)),
                ),
                shadows: [
                  const BoxShadow(
                    color: const Color(0xFFEEEEEE),
                    blurRadius: 2,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 15.0),
                child: Text(
                  user.displayName != null ? user.displayName : user.email,
                  style: TextStyle(
                    fontSize: FONT_SIZE,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0, top: 10.0, right: 5.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  side: BorderSide(color: const Color(0xFFBDBDBD)),
                ),
                shadows: [
                  const BoxShadow(
                    color: const Color(0xFFEEEEEE),
                    blurRadius: 2,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 15.0),
                child: Text(user.email,
                    style: TextStyle(
                        fontSize: FONT_SIZE, color: const Color(0xFF9E9E9E))),
              ),
            ),
          ),
          Builder(
            builder: (context) {
              if (_isPasswordUser()) {
                return Padding(
                  padding: EdgeInsets.only(top: 35.0),
                  child: InkWell(
                    key: Key(KEY_PASSWORD),
                    child: Text(
                      getString(context, "change_user_password"),
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ChangePassword()));
                    },
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          Builder(
            builder: (context) {
              if (_isPasswordUser()) {
                return RaisedButton(
                  key: Key(KEY_DELETE_ACCOUNT),
                  color: Colors.red,
                  onPressed: () => deleteAccount(user, context),
                  child: Text(
                    getString(context, 'debug_delete_account_button'),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
         /* Builder(
            builder: (context) {
              if (_isPasswordUser()) {
                return RaisedButton(
                  color: Colors.grey,
                  onPressed: () async {
                    await _authenticationService.signOut(user);
                    Navigator.of(context).push((MaterialPageRoute(
                        builder: (context) => AuthenticationPage())));
                  },
                  child: Text(getString(context, 'signout_user')),
                );
              } else {
                return Container();
              }
            },
          ),*/
        ],
      ),
    );
  }

  bool _isPasswordUser() {
    final user = UserService().user;
    final passwordProvider =
        user.providerData.any((provider) => provider.providerId == "password");
    return passwordProvider != null;
  }

  Widget _buildProfilePicture(FirebaseUser user) {
    return Consumer<UserPictureProvider>(
      builder: (context, provider, _) {
        CircleAvatar userPicture;

        String selectedPicturePath = provider.selectedPicturePath;
        if (selectedPicturePath != null) {
          userPicture = CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: FileImage(File(selectedPicturePath)),
            radius: 24.0,
          );
        } else {
          if (user.photoUrl != null && user.photoUrl.isNotEmpty) {
            userPicture = CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(
                user.photoUrl,
              ),
              radius: 24.0,
            );
          } else {
            userPicture = CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.grey,
              ),
              radius: 24.0,
            );
          }
        }

        return GestureDetector(
          key: Key(getString(context, "app_name")),
          onTap: () => _selectPicture(provider),
          child: userPicture,
        );
      },
    );
  }

  void openAuthenticationPage(context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void deleteAccount(FirebaseUser user, BuildContext context) {
    if (user != null) {
      try {
        user.delete();
        Fluttertoast.showToast(
            msg: getString(context, 'debug_account_deleted'));
        openAuthenticationPage(context);
        UserService().user = null;
      } catch (e) {
        debugPrint(e);
      }
    } else {
      Fluttertoast.showToast(msg: getString(context, 'no_user'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _auth.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return buildContent(context, snapshot.data);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}