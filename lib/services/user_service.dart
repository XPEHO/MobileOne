import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserService with ChangeNotifier {
  static FirebaseUser _user;

  FirebaseUser get user {
    return _user;
  }

  set user(FirebaseUser user) {
    _user = user;
    notifyListeners();
  }
}
