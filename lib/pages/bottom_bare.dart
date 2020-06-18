import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:MobileOne/services/navigation_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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



var navigationBarService = GetIt.I.get<NavigationBarService>();

class BottomBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BottomBarState();
  }
}

class BottomBarState extends State<BottomBar> {
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

  Widget build(BuildContext context) {
    return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  MaterialButton(
                    key: Key(KEY_CARD_PAGE),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        loyaltyCardPageSelected();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.loyalty, color: _iconCardsColor),
                        Text(
                          getString(context, 'loyalty_cards'),
                          style: TextStyle(color: _cardsColor),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    key: Key(KEY_LISTS_PAGE),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        listPageSelected();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.list, color: _iconListColor),
                        Text(
                          getString(context, 'my_lists'),
                          style: TextStyle(color: _listColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      getString(
                        context,
                        _centerText[navigationBarService.currentTab],
                      ),
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  MaterialButton(
                    key: Key(KEY_SHARE_PAGE),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        sharePageSelected();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.share, color: _iconShareColor),
                        Text(
                          getString(context, 'shared'),
                          style: TextStyle(color: _shareColor),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    key: Key(KEY_PROFILE_PAGE),
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        profilePageSelected();
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, color: _iconProfileColor),
                        Text(
                          getString(context, 'profile'),
                          style: TextStyle(color: _profileColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
  }

  void profilePageSelected() {
    navigationBarService.currentScreen = Profile();
    navigationBarService.currentTab = PROFILE_PAGE;

    _cardsColor = BLACK;
    _listColor = BLACK;
    _shareColor = BLACK;
    _profileColor = ORANGE;

    _iconCardsColor = BLACK;
    _iconListColor = BLACK;
    _iconShareColor = BLACK;
    _iconProfileColor = ORANGE;
  }

  void sharePageSelected() {
    navigationBarService.currentScreen = Share();
    navigationBarService.currentTab = SHARE_PAGE;

    _cardsColor = BLACK;
    _listColor = BLACK;
    _shareColor = ORANGE;
    _profileColor = BLACK;

    _iconCardsColor = BLACK;
    _iconListColor = BLACK;
    _iconShareColor = ORANGE;
    _iconProfileColor = BLACK;
  }

  listPageSelected() {
    navigationBarService.currentScreen = Lists();
    navigationBarService.currentTab = LISTS_PAGE;

    _cardsColor = BLACK;
    _listColor = ORANGE;
    _shareColor = BLACK;
    _profileColor = BLACK;

    _iconCardsColor = BLACK;
    _iconListColor = ORANGE;
    _iconShareColor = BLACK;
    _iconProfileColor = BLACK;
  }

  loyaltyCardPageSelected() {
    navigationBarService.currentScreen = LoyaltyCards();
    navigationBarService.currentTab = CARD_PAGE;

    _cardsColor = ORANGE;
    _listColor = BLACK;
    _shareColor = BLACK;
    _profileColor = BLACK;

    _iconCardsColor = ORANGE;
    _iconListColor = BLACK;
    _iconShareColor = BLACK;
    _iconProfileColor = BLACK;
  }
}
