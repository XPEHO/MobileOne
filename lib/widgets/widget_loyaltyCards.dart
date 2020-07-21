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

  @override
  void initState() {
    _controller.text = _card["label"];
    super.initState();
  }

  Color randomColor;

  Widget build(BuildContext context) {
    randomColor = Color(getColorFromHex(_card["color"]));
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Stack(
        children: <Widget>[
          Container(
            height: 110,
            width: 240,
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
          Padding(
            padding: const EdgeInsets.only(left: 30.0, top: 10.0, bottom: 8.0),
            child: Container(
              height: 90,
              width: 190,
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
                      padding: const EdgeInsets.only(top: 7),
                      child: Container(
                        height: 60,
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
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Container(
                        height: 20,
                        width: 180,
                        child: TextField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                          controller: _controller,
                          decoration: InputDecoration(
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
          Padding(
            padding: const EdgeInsets.all(8.0),
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
