import 'package:MobileOne/localization/localization.dart';
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
  bool isSelected=false;
var isOn=false;
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            BottomBarItem(
              KEY_CARD_PAGE,
              computeColor(CARD_PAGE),
              () => onSelectItem(CARD_PAGE),
              getString(context, 'loyalty_cards'),
              Icons.card_giftcard,
               () => test(),
            ),
            BottomBarItem(
              
              KEY_LISTS_PAGE,
              computeColor(LISTS_PAGE),
              () => onSelectItem(LISTS_PAGE),
              getString(context, 'my_lists'),
              Icons.list,
               () => test(),
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
              KEY_SHARE_PAGE,
              computeColor(SHARE_PAGE),
              () => onSelectItem(SHARE_PAGE),
              getString(context, 'shared'),
              Icons.share,
               () => test(),
            ),
            BottomBarItem(
              KEY_PROFILE_PAGE,
              computeColor(PROFILE_PAGE),
              () => onSelectItem(PROFILE_PAGE),
              getString(context, 'profile'),
              Icons.person,
             () => test(),
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
  bool test(){
    isSelected=true;
    return isSelected;
  }

}

class BottomBarItem extends StatelessWidget {
  final String _key;
  final Function _onItemTap;
  final Color _itemColor;
  final String _text;
  final IconData _icon;
  final Function isSelected;

  BottomBarItem(
      this._key, this._itemColor, this._onItemTap, this._text, this._icon,this.isSelected);

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
