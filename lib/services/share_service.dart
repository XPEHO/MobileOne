import 'package:flutter/material.dart';

class ShareService with ChangeNotifier {
  String _number;

  String get numberOfItemShared {
    return _number;
  }

  set numberOfItemShare(String number) {
    _number = number;
    notifyListeners();
  }
}
