import 'package:MobileOne/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPictureProvider with ChangeNotifier {
  final _userService = GetIt.I.get<UserService>();
  String _selectedPicturePath;

  UserPictureProvider() {
    _fetchSelectedPictureFromPreferences();
  }

  set selectedPicturePath(String imageFinale) {
    _selectedPicturePath = imageFinale;
    notifyListeners();
  }

  get selectedPicturePath => _selectedPicturePath;

  _fetchSelectedPictureFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedPicturePath = prefs.getString('picture' + _userService.user.uid);
  }
}
