import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';

const int CARD_PAGE = 0;
const int LISTS_PAGE = 1;
const int SHARE_PAGE = 2;
const int PROFILE_PAGE = 3;

const KEY_CENTER_TEXT = "center_text";
const KEY_CARD_PAGE = "Cards";
const KEY_LISTS_PAGE = "Lists";
const KEY_SHARE_PAGE = "Share";
const KEY_PROFILE_PAGE = "Profile";

const Color BLACK = Colors.black;
const Color ORANGE = Colors.deepOrange;

typedef IndexChangeListener = void Function(int);

class BottomBar extends StatefulWidget {
  final IndexChangeListener onItemSelected;

  BottomBar(this.onItemSelected);

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

  int _currentItem;

  Color computeColor(int index) => index == _currentItem ? ORANGE : BLACK;

  @override
  void initState() {
    super.initState();
    _currentItem = LISTS_PAGE;
  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            BottomBarItem(
              _currentItem == CARD_PAGE
                  ? KEY_CARD_PAGE + "_selected"
                  : KEY_CARD_PAGE,
              computeColor(CARD_PAGE),
              () => onSelectItem(CARD_PAGE),
              getString(context, 'loyalty_cards'),
              Icons.card_giftcard,
            ),
            BottomBarItem(
              _currentItem == LISTS_PAGE
                  ? KEY_LISTS_PAGE + "_selected"
                  : KEY_LISTS_PAGE,
              computeColor(LISTS_PAGE),
              () => onSelectItem(LISTS_PAGE),
              getString(context, 'my_lists'),
              Icons.list,
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
                  _centerText[_currentItem],
                ),
                key: Key(KEY_CENTER_TEXT),
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
            BottomBarItem(
              _currentItem == SHARE_PAGE
                  ? KEY_SHARE_PAGE + "_selected"
                  : KEY_SHARE_PAGE,
              computeColor(SHARE_PAGE),
              () => onSelectItem(SHARE_PAGE),
              getString(context, 'shared'),
              Icons.share,
            ),
            BottomBarItem(
              _currentItem == PROFILE_PAGE
                  ? KEY_PROFILE_PAGE + "_selected"
                  : KEY_PROFILE_PAGE,
              computeColor(PROFILE_PAGE),
              () => onSelectItem(PROFILE_PAGE),
              getString(context, 'profile'),
              Icons.person,
            ),
          ],
        ),
      ],
    );
  }

  void onSelectItem(int index) {
    setState(() {
      _currentItem = index;
    });
    widget.onItemSelected(index);
  }
}

class BottomBarItem extends StatelessWidget {
  final String _key;
  final Function _onItemTap;
  final Color _itemColor;
  final String _text;
  final IconData _icon;

  BottomBarItem(
      this._key, this._itemColor, this._onItemTap, this._text, this._icon);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      key: Key(_key),
      minWidth: 40,
      onPressed: () => _onItemTap(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(_icon, color: _itemColor),
          Text(
            _text,
            style: TextStyle(color: _itemColor),
          ),
        ],
      ),
    );
  }
}
