import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/services/loyalty_cards_service.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class LoyaltyCardsWidget extends StatefulWidget {
  final Map<String, dynamic> _card;
  final String _uuidcard;
  final TextEditingController _controller;
  LoyaltyCardsWidget(this._card, this._uuidcard, this._controller);

  State<StatefulWidget> createState() {
    return LoyaltyCardsWidgetState(_card, _uuidcard, _controller);
  }
}

class LoyaltyCardsWidgetState extends State<LoyaltyCardsWidget> {
  var userService = GetIt.I.get<UserService>();
  var _loyaltyCardsService = GetIt.I.get<LoyaltyCardsService>();
  final Map<String, dynamic> _card;
  final String _uuidcard;
  final TextEditingController _controller;
  LoyaltyCardsWidgetState(this._card, this._uuidcard, this._controller);

  FocusNode _focus = new FocusNode();
  bool isBarcodeSquare = false;
  bool isWishlistNameModified = false;

  Color cardColor;

  @override
  void initState() {
    _controller.text = _card["label"];
    if (_card["label"].length > 20) {
      _controller.text = _card["label"].substring(0, 20) + "...";
    } else {
      _controller.text = _card["label"];
    }
    _focus.addListener(_onFocusChange);
    super.initState();
  }

  void _onFocusChange() {
    _controller.text = _card["label"];
  }

  Widget build(BuildContext context) {
    cardColor = Color(_loyaltyCardsService.getColorFromHex(_card["color"]));
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: InkWell(
        onTap: () {
          openCardsPage();
        },
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.21,
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(22),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width * 0.1,
              top: MediaQuery.of(context).size.width * 0.04,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.17,
                width: MediaQuery.of(context).size.width * 0.60,
                decoration: BoxDecoration(
                  color: WHITE,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.09,
                          width: 180,
                          child: getBarcodeWidget(),
                        ),
                      ),
                      buildNamePadding(context),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.width * 0.02,
              left: MediaQuery.of(context).size.width * 0.02,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: WHITE,
                  borderRadius: BorderRadius.all(
                    Radius.circular(50),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding buildNamePadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              focusNode: _focus,
              maxLines: 1,
              inputFormatters: [
                LengthLimitingTextInputFormatter(40),
              ],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
              controller: _controller,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                isDense: true,
                hintText: getString(context, "card_name"),
              ),
              onSubmitted: (_) {
                updateLoyaltyCards(_controller.text);
                setState(() {
                  isWishlistNameModified = false;
                });
              },
              onChanged: (_) {
                if (!isWishlistNameModified) {
                  setState(() {
                    isWishlistNameModified = true;
                  });
                }
              },
            ),
          ),
          isWishlistNameModified
              ? Flexible(
                  flex: 1,
                  child: InkWell(
                    onTap: () {
                      updateLoyaltyCards(_controller.text);
                      setState(() {
                        isWishlistNameModified = false;
                      });
                    },
                    child: Icon(
                      Icons.check,
                      color: GREEN,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  BarcodeWidget getBarcodeWidget() {
    switch (_card["format"]) {
      case "ean13":
        return BarcodeWidget(
          barcode: Barcode.ean13(),
          data: _card["barecode"],
        );
        break;
      case "code128":
        return BarcodeWidget(
          barcode: Barcode.code128(),
          data: _card["barecode"],
        );
        break;
      case "code39":
        return BarcodeWidget(
          barcode: Barcode.code39(),
          data: _card["barecode"],
        );
        break;
      case "code93":
        return BarcodeWidget(
          barcode: Barcode.code93(),
          data: _card["barecode"],
        );
        break;
      case "dataMatrix":
        return BarcodeWidget(
          barcode: Barcode.dataMatrix(),
          data: _card["barecode"],
        );
        break;
      case "ean2":
        return BarcodeWidget(
          barcode: Barcode.ean2(),
          data: _card["barecode"],
        );
        break;
      case "ean5":
        return BarcodeWidget(
          barcode: Barcode.ean5(),
          data: _card["barecode"],
        );
        break;
      case "ean8":
        return BarcodeWidget(
          barcode: Barcode.ean8(),
          data: _card["barecode"],
        );
        break;
      case "gs128":
        return BarcodeWidget(
          barcode: Barcode.gs128(),
          data: _card["barecode"],
        );
        break;
      case "isbn":
        return BarcodeWidget(
          barcode: Barcode.isbn(),
          data: _card["barecode"],
        );
        break;
      case "itf":
        return BarcodeWidget(
          barcode: Barcode.itf(),
          data: _card["barecode"],
        );
        break;
      case "itf14":
        return BarcodeWidget(
          barcode: Barcode.itf14(),
          data: _card["barecode"],
        );
        break;
      case "pdf417":
        return BarcodeWidget(
          barcode: Barcode.pdf417(),
          data: _card["barecode"],
        );
        break;
      case "qr":
        return BarcodeWidget(
          barcode: Barcode.qrCode(),
          data: _card["barecode"],
        );
        break;
      case "rm4scc":
        return BarcodeWidget(
          barcode: Barcode.rm4scc(),
          data: _card["barecode"],
        );
        break;
      case "aztec":
        return BarcodeWidget(
          barcode: Barcode.aztec(),
          data: _card["barecode"],
        );
        break;
      case "upce":
        return BarcodeWidget(
          barcode: Barcode.upcE(),
          data: _card["barecode"],
        );
        break;
      case "upca":
        return BarcodeWidget(
          barcode: Barcode.upcA(),
          data: _card["barecode"],
        );
        break;
      case "codabar":
        return BarcodeWidget(
          barcode: Barcode.codabar(),
          data: _card["barecode"],
        );
        break;
      case "telepen":
        return BarcodeWidget(
          barcode: Barcode.telepen(),
          data: _card["barecode"],
        );
        break;
      default:
        return BarcodeWidget(
          barcode: Barcode.ean13(),
          data: _card["barecode"],
        );
        break;
    }
  }

  updateLoyaltyCards(String _name) async {
    GetIt.I.get<LoyaltyCardsProvider>().updateLoyaltyCards(_name, _uuidcard);
  }

  openCardsPage() {
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(context, '/cards', arguments: _uuidcard);
  }
}
