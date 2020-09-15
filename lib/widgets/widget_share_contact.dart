import 'dart:typed_data';
import 'dart:math';
import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class WidgetShareContact extends StatefulWidget {
  final Uint8List avatar;
  final String name;
  final String email;
  WidgetShareContact({this.name, this.avatar, this.email});
  State<StatefulWidget> createState() => WidgetShareContactState();
}

class WidgetShareContactState extends State<WidgetShareContact> {
  var _colorsApp = GetIt.I.get<ColorService>();
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _colorsApp.buttonColor,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          (widget.avatar != null && widget.avatar.length > 0)
              ? CircleAvatar(
                  backgroundImage: MemoryImage(widget.avatar),
                )
              : (widget.email.length > 2)
                  ? (widget.name != null)
                      ? CircleAvatar(
                          backgroundColor: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          child: Text(widget.name.substring(0, 2)))
                      : CircleAvatar(
                          backgroundColor: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          child: Text(
                              getString(context, "undefined_contact_name")
                                  .substring(0, 2)))
                  : CircleAvatar(
                      backgroundColor: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)],
                      child: Text(widget.email.substring(0, 2)),
                    ),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  (widget.name != null)
                      ? Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: WHITE,
                          ),
                        )
                      : Text(
                          getString(context, "undefined_contact_name"),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: WHITE,
                          ),
                        ),
                  Text(
                    widget.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: WHITE,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
