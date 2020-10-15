import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/color_service.dart';
import 'package:MobileOne/services/tutorial_service.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_custom_drawer.dart';
import 'package:MobileOne/widgets/widget_loyaltyCards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/target_position.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class LoyaltyCards extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoyaltyCardsState();
  }
}

class LoyaltyCardsState extends State<LoyaltyCards> {
  String uuidOfCard;
  var _analytics = GetIt.I.get<AnalyticsService>();
  var _colorsApp = GetIt.I.get<ColorService>();
  final _tutorialService = GetIt.I.get<TutorialService>();

  List<TargetFocus> targets = List();

  @override
  void initState() {
    _analytics.setCurrentPage("isOnLoyaltyCardPage");
    super.initState();
  }

  void initTargets() {
    targets.add(
      _tutorialService.createTarget(
        identifier: "Scan a card",
        position: TargetPosition(
            Size(40, 40),
            Offset(
              (MediaQuery.of(context).size.width / 2) - 20,
              MediaQuery.of(context).size.height - 80,
            )),
        title: getString(context, "tutorial_scan_card_title"),
        text: getString(context, "tutorial_scan_card_text"),
        positionBottom: 200,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initTargets();
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<LoyaltyCardsProvider>(),
      child: Consumer<LoyaltyCardsProvider>(
          builder: (context, loyaltyCardsProvider, child) {
        return Builder(builder: (BuildContext context) {
          return content(loyaltyCardsProvider.allLoyaltycards);
        });
      }),
    );
  }

  Widget content(Map<String, dynamic> card) {
    final cards = card ?? {};
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _colorsApp.colorTheme,
      ),
      drawer: CustomDrawer(
        context: context,
        targets: targets,
      ),
      backgroundColor: _colorsApp.colorTheme,
      body: SafeArea(
        child:
            (cards.isNotEmpty) ? buildLoyaltycards(cards) : emptyLoyaltycards(),
      ),
    );
  }

  Column emptyLoyaltycards() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.21,
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: _colorsApp.buttonColor,
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
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.09,
                  width: 180,
                  child: Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/images/qr-code.svg",
                      width: 70,
                      height: 70,
                      color: _colorsApp.buttonColor,
                    ),
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
        Text(
          getString(context, "empty_cards"),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: WHITE,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Container buildLoyaltycards(cards) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 32,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          bottom: kFloatingActionButtonMargin + 24,
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: cards.length,
        itemBuilder: (BuildContext ctxt, int index) {
          List<TextEditingController> controllerList =
              List.generate(cards.length, (index) {
            return TextEditingController();
          });
          uuidOfCard = cards.keys.toList()[index];
          return Dismissible(
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content:
                          Text(getString(context, 'confirm_card_deletion')),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(getString(context, 'delete_item'))),
                        FlatButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(getString(context, 'cancel_deletion')),
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(color: RED),
              key: UniqueKey(),
              child: Center(
                  child: LoyaltyCardsWidget(cards.values.toList()[index],
                      uuidOfCard, controllerList[index])),
              onDismissed: (direction) {
                deleteCard(cards.keys.toList()[index]);
              });
        },
      ),
    );
  }

  void deleteCard(String uuid) {
    GetIt.I.get<LoyaltyCardsProvider>().deleteCard(uuid);
    _analytics.sendAnalyticsEvent("delete_loyalty_card");
  }
}
