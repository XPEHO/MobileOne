
import 'package:MobileOne/pages/bottom_bare.dart';
import 'package:MobileOne/pages/lists.dart';

import 'package:flutter/material.dart';

const int CARD_PAGE = 0;
const int LISTS_PAGE = 1;
const int SHARE_PAGE = 2;
const int PROFILE_PAGE = 3;

const KEY_CARD_PAGE = "Cards";
const KEY_LISTS_PAGE = "Lists";
const KEY_SHARE_PAGE = "Share";
const KEY_PROFILE_PAGE = "Profile";

const Color BLACK = Colors.black;
const Color ORANGE = Colors.deepOrange;

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  int _currentTab = CARD_PAGE;
  Widget _currentScreen = Lists();
  final List _centerIcons = [
    Icons.scanner,
    Icons.add,
    Icons.share,
    Icons.camera,
  ];



  final PageStorageBucket _bucket = PageStorageBucket();



  @override
  Widget build(BuildContext context) {
    print("IM HERE MAINPAGE");

    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _currentScreen),
      floatingActionButton: FloatingActionButton(
        child: Icon(_centerIcons[_currentTab]),
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (_currentTab == LISTS_PAGE) {
            goToCreateListPage();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: BottomBar(),
        ),
      ),
    );
  }

 
  
  goToCreateListPage() {
    Navigator.of(context).pushNamed('/createList');
  }

  
}
