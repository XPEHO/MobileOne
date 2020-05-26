import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/lists.dart';
import 'package:MobileOne/pages/loyalty_card.dart';
import 'package:MobileOne/pages/profile.dart';
import 'package:MobileOne/pages/share.dart';
import 'package:flutter/material.dart';

const int CARD_PAGE = 0;
const int LISTS_PAGE = 1;
const int SHARE_PAGE = 2;
const int PROFILE_PAGE = 3;

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}


class MainPageState extends State<MainPage> {
  
   int _currentTab = CARD_PAGE;

  final List _centerIcons =[
    Icons.scanner,
    Icons.add,
    Icons.share,
    Icons.camera,
  ];

    final List _centerText =[
    'center_icon_loyaltycards',
    'center_icon_newlist',
    'center_icon_share',
    'center_icon_profile'
  ];

  Widget _currentScreen = Lists();
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:PageStorage(bucket: _bucket, child: _currentScreen),
        floatingActionButton: FloatingActionButton(
          child:Icon(_centerIcons[_currentTab]),
          backgroundColor: Colors.orangeAccent,
          onPressed: (){},
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          child:Container(
            height: 60,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
              Row(
                children:<Widget>[
                  MaterialButton(
                    key:Key("Cards"),
                    minWidth:40,
                    onPressed:(){
                      setState((){
                        _currentScreen = LoyaltyCards();
                        _currentTab = CARD_PAGE;
                      });
                    },
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Icon(Icons.loyalty),
                        Text(getString(context,'loyalty_cards'))
                      ]
                    )
                  ),
                  MaterialButton(
                    key:Key("List"),
                    minWidth:40,
                    onPressed:(){
                      setState((){
                        _currentScreen = Lists();
                        _currentTab = LISTS_PAGE;
                      });
                    },
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Icon(Icons.list),
                        Text(getString(context,'my_lists'), key: Key("Lists"),)
                      ]
                    )
                  ),
                ]
              ),
              Expanded(
                child:Padding(
                  padding: const EdgeInsets.only(top:25.0),
                  child:Center(
                      child: Text(
                        getString(context, _centerText[_currentTab]),
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                        
                      )
                  ),
                ),
              ),
              Row(
                children:<Widget>[
                  MaterialButton(
                    key:Key("Share"),
                    minWidth:40,
                    onPressed:(){
                      setState((){
                        _currentScreen = Share();
                        _currentTab = SHARE_PAGE;
                      });
                    },
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Icon(Icons.share),
                        Text(getString(context,'shared'))
                      ]
                    )
                  ),
                  MaterialButton(
                    key:Key("Profile"),
                    minWidth:40,
                    onPressed:(){
                      setState((){
                        _currentScreen = Profile();
                        _currentTab = PROFILE_PAGE;
                      });
                    },
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:<Widget>[
                        Icon(Icons.person),
                        Text(getString(context,'profile'))
                      ]
                    )
                  ),
                ]
              ),
            ],
            )
          )
        ), 
    );
  }
}