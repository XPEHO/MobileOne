import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/loyalty_cards_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

class Cards extends StatefulWidget {
  @override
  CardsState createState() => CardsState();
}

class CardsState extends State<Cards> with TickerProviderStateMixin {
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  var _loyaltycardsProvider = GetIt.I.get<LoyaltyCardsProvider>();
  var _userService = GetIt.I.get<UserService>();
  var _loyaltyCardsService = GetIt.I.get<LoyaltyCardsService>();

  String cardUuid;
  ColorSwatch _tempMainColor;
  ColorSwatch _mainColor = Colors.blue;
  Color cardColor;
  var card;

  Animation _rotation, _scale;
  AnimationController _rotationController, _scaleController;

  @override
  void initState() {
    _analytics.setCurrentPage("isOnBigCardPage");
    super.initState();

    _rotationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _rotation = Tween(begin: 0.0, end: -(pi / 2)).animate(_rotationController);

    _scaleController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _scale = Tween(begin: 1.0, end: 0.7).animate(_scaleController);
  }

  void _openDialog(String title, Widget content) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text(title),
          content: content,
          actions: [
            FlatButton(
              child: Text('CANCEL'),
              onPressed: Navigator.of(context).pop,
            ),
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  _mainColor = _tempMainColor;
                });
                addColorToDabase();
              },
            ),
          ],
        );
      },
    );
  }

  void _openMainColorPicker() async {
    _openDialog(
      "Main Color picker",
      MaterialColorPicker(
        selectedColor: _mainColor,
        allowShades: false,
        onMainColorChange: (color) => setState(() => _tempMainColor = color),
      ),
    );
  }

  addColorToDabase() async {
    await _loyaltycardsProvider.updateLoyaltycardsColor(
        (_mainColor != Colors.blue)
            ? '#${_mainColor.value.toRadixString(16)}'
            : '#${card["color"].value.toRadixString(16)}',
        cardUuid,
        _userService.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    cardUuid = ModalRoute.of(context).settings.arguments;
    card = _loyaltycardsProvider.allLoyaltycards[cardUuid];
    cardColor = (_tempMainColor != null)
        ? _mainColor
        : Color(_loyaltyCardsService.getColorFromHex(card["color"]));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorsApp.colorTheme,
        actions: [
          FlatButton(
            onPressed: () {
              _openMainColorPicker();
            },
            child: Icon(
              Icons.color_lens,
              color: WHITE,
            ),
          ),
          IconButton(
              icon: Icon(Icons.rotate_90_degrees_ccw),
              onPressed: () => _animate()),
        ],
      ),
      backgroundColor: _colorsApp.colorTheme,
      body: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Transform.rotate(
              angle: _rotation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                              color: cardColor,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.width * 0.55,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.2,
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Transform(
                              child: getBarcodeWidget(card),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
                                alignment: Alignment.center,
                                child: Text(
                                  card["label"],
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50))),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _animate() {
    _rotationController.isCompleted
        ? _rotationController.reverse()
        : _rotationController.forward();
    _scaleController.isCompleted
        ? _scaleController.reverse()
        : _scaleController.forward();
  }

  goToLoyaltyCardsPage(context) async {
    final result = await Navigator.of(context).pushNamed(
      "/mainPage",
    );
    Navigator.of(context).pop(result);
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
}
