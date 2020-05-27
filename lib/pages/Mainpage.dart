import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const int CARD_PAGE = 0;
const int LISTS_PAGE = 1;
const int SHARE_PAGE = 2;
const int PROFILE_PAGE = 3;

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

  final List _centerIcons = [
    Icons.scanner,
    Icons.add,
    Icons.share,
    Icons.camera,
  ];

  final List _centerText = [
    'center_icon_loyaltycards',
    'center_icon_newlist',
    'center_icon_share',
    'center_icon_profile'
  ];

  Color _cardsColor, _listColor, _shareColor, _profileColor;
  Color _iconCardsColor,
      _iconListColor,
      _iconShareColor,
      _iconProfileColor = BLACK;
  Widget _currentScreen = Lists();
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: _bucket, child: _currentScreen),
      floatingActionButton: FloatingActionButton(
        child: Icon(_centerIcons[_currentTab]),
        backgroundColor: Colors.deepOrange,
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(children: <Widget>[
                MaterialButton(
                    key: Key("Cards"),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        _currentScreen = LoyaltyCards();
                        _currentTab = CARD_PAGE;

                        _cardsColor = ORANGE;
                        _listColor = BLACK;
                        _shareColor = BLACK;
                        _profileColor = BLACK;

                        _iconCardsColor = ORANGE;
                        _iconListColor = BLACK;
                        _iconShareColor = BLACK;
                        _iconProfileColor = BLACK;
                      });
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.loyalty, color: _iconCardsColor),
                          Text(getString(context, 'loyalty_cards'),
                              style: TextStyle(color: _cardsColor))
                        ])),
                MaterialButton(
                    key: Key("Lists"),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        _currentScreen = Lists();
                        _currentTab = LISTS_PAGE;

                        _cardsColor = BLACK;
                        _listColor = ORANGE;
                        _shareColor = BLACK;
                        _profileColor = BLACK;

                        _iconCardsColor = BLACK;
                        _iconListColor = ORANGE;
                        _iconShareColor = BLACK;
                        _iconProfileColor = BLACK;
                      });
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.list, color: _iconListColor),
                          Text(getString(context, 'my_lists'),
                              style: TextStyle(color: _listColor)),
                        ])),
              ]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Center(
                      child: Text(
                    getString(
                      context,
                      _centerText[_currentTab],
                    ),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12.0,
                    ),
                  )),
                ),
              ),
              Row(
                children: <Widget>[
                  MaterialButton(
                      key: Key("Share"),
                      minWidth: 40,
                      onPressed: () {
                        setState(() {
                          _currentScreen = Share();
                          _currentTab = SHARE_PAGE;

                          _cardsColor = BLACK;
                          _listColor = BLACK;
                          _shareColor = ORANGE;
                          _profileColor = BLACK;

                          _iconCardsColor = BLACK;
                          _iconListColor = BLACK;
                          _iconShareColor = ORANGE;
                          _iconProfileColor = BLACK;
                        });
                      },
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.share, color: _iconShareColor),
                            Text(getString(context, 'shared'),
                                style: TextStyle(color: _shareColor))
                          ])),
                  MaterialButton(
                    key: Key("Profile"),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        _currentScreen = Profile(FirebaseAuth.instance);
                        _currentTab = PROFILE_PAGE;

                        _cardsColor = BLACK;
                        _listColor = BLACK;
                        _shareColor = BLACK;
                        _profileColor = ORANGE;

                        _iconCardsColor = BLACK;
                        _iconListColor = BLACK;
                        _iconShareColor = BLACK;
                        _iconProfileColor = ORANGE;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: _iconProfileColor),
                        Text(getString(context, 'profile'),
                            style: TextStyle(color: _profileColor))
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
