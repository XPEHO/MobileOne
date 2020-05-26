import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Profile extends StatelessWidget {
  // This widget is the root of your application.
  @override
 Widget build(BuildContext context){

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(getString(context, "profile")),
            RaisedButton(
              key: Key("debug_delete_account_button"),
              color: Colors.red,
              onPressed: () => deleteAccount(UserService().user, context),
              child: Text(getString(context, 'debug_delete_account_button'))
            ),
          ],
        ),
      )
    );
  }

  void openAuthenticationPage(context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  void deleteAccount(FirebaseUser user, BuildContext context) {
    if (user != null) {
      try {       
        user.delete();
        Fluttertoast.showToast(msg: getString(context, 'debug_account_deleted'));
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