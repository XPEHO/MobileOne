import 'package:flutter/material.dart';

class EmptyLists extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color textAndIconColor;
  EmptyLists({this.text, this.icon, this.color, this.textAndIconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      child: Card(
        elevation: 3,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: textAndIconColor),
            ),
            Icon(
              icon,
              color: textAndIconColor,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
