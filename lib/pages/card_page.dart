import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/utility/arguments.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Cards extends StatefulWidget {
  @override
  CardsState createState() => CardsState();
}

class CardsState extends State<Cards> {
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  @override
  void initState() {
    _analytics.setCurrentPage("isOnBigCardPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CardArguments args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      backgroundColor: _colorsApp.colorTheme,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: WHITE),
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
                    child: getBarcodeWidget(args.cards),
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

  BarcodeWidget getBarcodeWidget(Map<String, dynamic> _card) {
    switch (_card["format"]) {
      case "ean13":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.ean13(),
          data: _card["barecode"],
        );
        break;
      case "code128":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.code128(),
          data: _card["barecode"],
        );
        break;
      case "code39":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.code39(),
          data: _card["barecode"],
        );
        break;
      case "code93":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.code93(),
          data: _card["barecode"],
        );
        break;
      case "dataMatrix":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.dataMatrix(),
          data: _card["barecode"],
        );
        break;
      case "ean2":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.ean2(),
          data: _card["barecode"],
        );
        break;
      case "ean5":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.ean5(),
          data: _card["barecode"],
        );
        break;
      case "ean8":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.ean8(),
          data: _card["barecode"],
        );
        break;
      case "gs128":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.gs128(),
          data: _card["barecode"],
        );
        break;
      case "isbn":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.isbn(),
          data: _card["barecode"],
        );
        break;
      case "itf":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.itf(),
          data: _card["barecode"],
        );
        break;
      case "itf14":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.itf14(),
          data: _card["barecode"],
        );
        break;
      case "pdf417":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.pdf417(),
          data: _card["barecode"],
        );
        break;
      case "qr":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.qrCode(),
          data: _card["barecode"],
        );
        break;
      case "rm4scc":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.rm4scc(),
          data: _card["barecode"],
        );
        break;
      case "aztec":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.aztec(),
          data: _card["barecode"],
        );
        break;
      case "upce":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.upcE(),
          data: _card["barecode"],
        );
        break;
      case "upca":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.upcA(),
          data: _card["barecode"],
        );
        break;
      case "codabar":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.codabar(),
          data: _card["barecode"],
        );
        break;
      case "telepen":
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.telepen(),
          data: _card["barecode"],
        );
        break;
      default:
        return BarcodeWidget(
          style: TextStyle(fontSize: 20),
          barcode: Barcode.ean13(),
          data: _card["barecode"],
        );
        break;
    }
  }

  goToLoyaltyCardsPage() {
    Navigator.popUntil(context, ModalRoute.withName("/mainpage"));
  }
}
