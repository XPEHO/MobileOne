import 'package:MobileOne/pages/bottom_bar.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/share.dart';

import 'package:flutter/material.dart';

const Color BLACK = Colors.black;
const Color ORANGE = Colors.deepOrange;

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  Widget _currentScreen = Lists();
  final List _centerIcons = [
    Icons.scanner,
    Icons.add,
    Icons.share,
    Icons.camera,
  ];

  List _actions = [];

  IconData _floatingButtonIcon;
  Function _floatingButtonAction;

  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();
    _actions = [
      unasignedAction,
      goToCreateListPage,
      unasignedAction,
      unasignedAction,
    ];

    _floatingButtonIcon = _centerIcons[LISTS_PAGE];
    _floatingButtonAction = _actions[LISTS_PAGE];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _currentScreen),
      floatingActionButton: FloatingActionButton(
        child: Icon(_floatingButtonIcon),
        backgroundColor: Colors.deepOrange,
        onPressed: () => _floatingButtonAction(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: BottomBar(onBottomBarIndexSelected),
        ),
      ),
    );
  }

  onBottomBarIndexSelected(index) {
    setState(() {
      _floatingButtonIcon = _centerIcons[index];
      _floatingButtonAction = _actions[index];
      switch (index) {
        case CARD_PAGE:
          _currentScreen = LoyaltyCards();
          break;
        case LISTS_PAGE:
          _currentScreen = Lists();
          break;
        case SHARE_PAGE:
          _currentScreen = Share();
          break;
        case PROFILE_PAGE:
          _currentScreen = Profile();
          break;
      }
    });
  }

  unasignedAction() {
    debugPrint("no action assigned");
  }

  goToCreateListPage() {
    Navigator.of(context).pushNamed("/createList");
  }
}
