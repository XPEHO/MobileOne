import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/arguments.dart';
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
  final Map<String, dynamic> _card;
  final String _uuidcard;
  final TextEditingController _controller;
  LoyaltyCardsWidgetState(this._card, this._uuidcard, this._controller);
  FocusNode _focus = new FocusNode();

  @override
  void initState() {
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

  Color randomColor;

  Widget build(BuildContext context) {
    randomColor = Color(getColorFromHex(_card["color"]));
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.21,
            width: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
              color: randomColor,
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
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: 180,
                        child: GestureDetector(
                          onTap: () {
                            openCardsPage();
                          },
                          child: BarcodeWidget(
                            barcode: Barcode.ean13(),
                            data: _card["barecode"],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.4,
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
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 2, vertical: 0),
                            isDense: true,
                            hintText: getString(context, "card_name"),
                          ),
                          onSubmitted: (_) =>
                              updateLoyaltyCards(_controller.text),
                        ),
                      ),
                    ),
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
    );
  }

  int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  updateLoyaltyCards(String _name) async {
    GetIt.I.get<LoyaltyCardsProvider>().updateLoyaltyCards(_name, _uuidcard);
  }

  openCardsPage() {
    FocusScope.of(context).unfocus();
    Navigator.pushNamed(context, '/cards',
        arguments: CardArguments(_card, randomColor));
  }
}
