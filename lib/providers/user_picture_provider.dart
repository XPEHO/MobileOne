import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPictureProvider with ChangeNotifier {
  String _selectedPicturePath;

  UserPictureProvider(FirebaseUser user) {
    _fetchSelectedPictureFromPreferences(user);
  }

  set selectedPicturePath(String imageFinale) {
    _selectedPicturePath = imageFinale;
    notifyListeners();
  }

  get selectedPicturePath => _selectedPicturePath;

  _fetchSelectedPictureFromPreferences(FirebaseUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedPicturePath = prefs.getString('picture'+user.uid);
  }
}