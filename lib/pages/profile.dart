import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/authentication-page.dart';
import 'package:MobileOne/pages/change_password.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:MobileOne/services/authentication_service.dart';
import 'package:get_it/get_it.dart';

const double FONT_SIZE = 15;
const KEY_PASSWORD = "Password";
const KEY_DELETE_ACCOUNT = "debug_delete_account_button";

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  var _authenticationService = GetIt.I.get<AuthenticationService>();
  final auth = GetIt.I.get<FirebaseAuth>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: auth.currentUser(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildContent(context, snapshot.data);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Scaffold buildContent(BuildContext context, FirebaseUser user) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
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
                    borderRadius: BorderRadius.circular(24),
                    elevation: 8.0,
                    child: Builder(
                      builder: (context) {
                        if (user.photoUrl == null || user.photoUrl.isEmpty) {
                          return Container();
                        } else {
                          return CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(user.photoUrl),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
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
                  child: Text(
                    user.email,
                    style: TextStyle(
                      fontSize: FONT_SIZE,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 35.0),
              child: InkWell(
                  child: Text(getString(context, "change_password"),
                      key: Key(KEY_PASSWORD),
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      )),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangePassword(),
                      ),
                    );
                  }),
            ),
            RaisedButton(
              key: Key(KEY_DELETE_ACCOUNT),
              color: Colors.red,
              onPressed: () => deleteAccount(user, context),
              child: Text(
                getString(context, 'debug_delete_account_button'),
              ),
            ),
            RaisedButton(
              color: Colors.grey,
              onPressed: () async {
                await _authenticationService.signOut(user);
                Navigator.of(context).push((MaterialPageRoute(
                    builder: (context) => AuthenticationPage())));
              },
              child: Text(getString(context, 'signout_user')),
            ),
          ],
        ),
      ),
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
}
