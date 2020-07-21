import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

class Cards extends StatefulWidget {
  @override
  CardsState createState() => CardsState();
}

class CardsState extends State<Cards> {
  @override
  Widget build(BuildContext context) {
    CardArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  goToLoyaltyCardsPage();
                },
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                    color: args.colorOfCard,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(5),
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22))),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 70.0, left: 32),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                      color: WHITE,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.6,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Transform(
                    child: BarcodeWidget(
                      style: TextStyle(fontSize: 20),
                      height: 100,
                      width: 350,
                      barcode: Barcode.ean13(),
                      data: args.cards["barecode"],
                    ),
                    alignment: FractionalOffset.center,
                    transform: new Matrix4.identity()
                      ..rotateZ(90 * 3.1415927 / 180),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.7,
                right: MediaQuery.of(context).size.width * 0.3,
                child: Transform(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    alignment: Alignment.center,
                    child: Text(
                      args.cards["label"],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  alignment: FractionalOffset.center,
                  transform: new Matrix4.identity()
                    ..rotateZ(91 * 3.1415927 / 180),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 240, top: 10),
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: WHITE,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  goToLoyaltyCardsPage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainpage"));
  }
}
