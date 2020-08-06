import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';

class EmptyLists extends StatelessWidget {
  final String text;
  final IconData icon;
  EmptyLists({this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      child: Card(
        elevation: 3,
        color: WHITE,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: GREY),
            ),
            Icon(icon, color: GREY),
          ],
        ),
      ),
    );
  }
}
