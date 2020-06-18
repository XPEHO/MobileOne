import 'package:MobileOne/pages/lists.dart';
import 'package:flutter/material.dart';

const int CARD_PAGE = 0;
class NavigationBarService with ChangeNotifier {
  
int _currentTab = CARD_PAGE;
Widget _currentScreen = Lists();

  int get currentTab {
    return _currentTab;
  }

  set currentTab(int value) {
    _currentTab = value;
    notifyListeners();
  }


  Widget get currentScreen {
    return _currentScreen;
  }

  set currentScreen(Widget value) {
    _currentScreen = value;
    notifyListeners();
  }
}
