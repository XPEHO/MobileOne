import 'dart:typed_data';
import 'package:flutter/material.dart';

const Color GREEN = Colors.green;

class WidgetShareContact extends StatefulWidget {
  final Uint8List avatar;
  final String name;
  WidgetShareContact(this.name, this.avatar);
  State<StatefulWidget> createState() => WidgetShareContactState();
}

class WidgetShareContactState extends State<WidgetShareContact> {
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: (widget.avatar != null && widget.avatar.length > 0)
              ? CircleAvatar(
                  backgroundImage: MemoryImage(widget.avatar),
                )
              : CircleAvatar(
                  child: Text(widget.name.substring(0, 2)),
                ),
        ),
        Text(
          widget.name,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        Container(),
      ],
    );
  }
}
