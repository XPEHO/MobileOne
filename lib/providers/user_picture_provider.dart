import 'package:flutter/material.dart';

class UserPictureProvider with ChangeNotifier {
  String _selectedPicturePath;

  set selectedPicturePath(String imageFinale) {
    _selectedPicturePath = imageFinale;
    notifyListeners();
  }

  get selectedPicturePath => _selectedPicturePath;
}
