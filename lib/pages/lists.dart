import 'package:MobileOne/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Color ORANGE = Colors.deepOrange;
final List<Widget> widgetList = [];

class Lists extends StatefulWidget {
  State<StatefulWidget> createState() {
    return ListsState();
  }
}

class ListsState extends State<Lists> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 200.0, right: 300),
            child: Text(
              getString(context, 'my_lists'),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: ListView(
              children: <Widget>[
                Row(
                  children: widgetList,
                ),
              ],
              scrollDirection: Axis.horizontal,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Text(
              getString(context, 'shared_with_me'),
            ),
          ),
        ],
      ),
    );
  }
}
