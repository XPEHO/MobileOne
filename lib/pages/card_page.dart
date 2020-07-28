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
              Positioned(
                top: MediaQuery.of(context).size.width * 0.2,
                left: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                      color: WHITE,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.55,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Transform(
                    child: BarcodeWidget(
                      style: TextStyle(fontSize: 20),
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
                right: MediaQuery.of(context).size.width * 0.04,
                child: Transform(
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.85,
                      alignment: Alignment.center,
                      child: Text(
                        args.cards["label"],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  alignment: FractionalOffset.center,
                  transform: new Matrix4.identity()
                    ..rotateZ(90 * 3.1415927 / 180),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.05,
                left: MediaQuery.of(context).size.width * 0.6,
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
