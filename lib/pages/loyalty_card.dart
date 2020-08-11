import 'package:MobileOne/localization/localization.dart';
import 'package:MobileOne/providers/loyalty_cards_provider.dart';
import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/utility/colors.dart';
import 'package:MobileOne/widgets/widget_loyaltyCards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class LoyaltyCards extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoyaltyCardsState();
  }
}

class LoyaltyCardsState extends State<LoyaltyCards> {
  String uuidOfCard;
  var _analytics = GetIt.I.get<AnalyticsService>();
  @override
  void initState() {
    _analytics.setCurrentPage("isOnLoyaltyCardPage");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: GetIt.I.get<LoyaltyCardsProvider>(),
      child: Consumer<LoyaltyCardsProvider>(
        builder: (context, loyaltyCardsProvider, child) {
          return FutureBuilder<DocumentSnapshot>(
            future: loyaltyCardsProvider.loyaltyCards,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator(
                  strokeWidth: 1,
                );
              else {
                return content(snapshot.data);
              }
            },
          );
        },
      ),
    );
  }

  Widget content(DocumentSnapshot snapshot) {
    final cards = snapshot?.data ?? {};

    return SafeArea(
      child: Container(
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
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text(getString(context, 'delete_item'))),
                            FlatButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child:
                                  Text(getString(context, 'cancel_deletion')),
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
            }),
      ),
    );
  }

  void deleteCard(String uuid) {
    GetIt.I.get<LoyaltyCardsProvider>().deleteCard(uuid);
    _analytics.sendAnalyticsEvent("delete_loyalty_card");
  }
}
