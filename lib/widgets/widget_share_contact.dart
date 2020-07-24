import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';

class WidgetShareContact extends StatefulWidget {
  final Uint8List avatar;
  final String name;
  final String email;
  WidgetShareContact(this.name, this.avatar, this.email);
  State<StatefulWidget> createState() => WidgetShareContactState();
}

class WidgetShareContactState extends State<WidgetShareContact> {
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        (widget.avatar != null && widget.avatar.length > 0)
            ? Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: CircleAvatar(
                  backgroundImage: MemoryImage(widget.avatar),
                ),
              )
            : Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: CircleAvatar(
                  backgroundColor: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)],
                  child: Text(widget.name.substring(0, 2)),
                ),
              ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              children: <Widget>[
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
