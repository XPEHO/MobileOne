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
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 30),
                child: (widget.avatar != null && widget.avatar.length > 0)
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(widget.avatar),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.primaries[
                            Random().nextInt(Colors.primaries.length)],
                        child: Text(widget.name.substring(0, 2)),
                      ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 150),
                child: Container(
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
              )
            ],
          ),
          Container(),
        ],
      ),
    );
  }
}
