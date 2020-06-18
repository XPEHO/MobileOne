import 'package:flutter/material.dart';

class ListsService with ChangeNotifier {
  List<String> _names = [];

  List<String> get listOfNames {
    return _names;
  }

  set listOfNames(List<String> names) {
    _names = names;
    notifyListeners();
  }
}
