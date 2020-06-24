import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/pages/wisget_popup.dart';
import 'package:flutter/material.dart';

const Color GREEN = Colors.green;
const Color GREY = Colors.grey;
const Color GREY600 = Colors.grey;
const Color RED = Colors.red;
const Color WHITE = Colors.white;
const Color TRANSPARENT = Colors.transparent;


Widget itemWidget(BuildContext context, String _itemName, String _itemCount,
    String _itemType) {
  return Row(
    children: [
      new Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: new Center(
          child: Stack(
            children: [
              Positioned(
                top: 25,
                left: 10,
                child: Container(
                  height: 50,
                  width: 50,
                  child: Image(
                    image: AssetImage("assets/images/bottle_of_water.png"),
                  ),
                ),
              ),
              Positioned(
                top: 30,
                left: 100,
                child: Text(
                  _itemName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: 100,
                child: Text(
                  _itemCount,
                  style: TextStyle(
                    color: GREY,
                  ),
                ),
              ),
              Positioned(
                left: 150,
                top: 60,
                child: Text(
                  _itemType,
                  style: TextStyle(
                    color: GREY,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 10,
                child: IconButton(
                  onPressed: () {
                     showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                             WidgetPopup(getString(context, 'popup_update'))
                          );
                  },
                  icon: Icon(Icons.edit),
                ),
              )
            ],
          ),
        ),
      ),
    ],
  );
}
