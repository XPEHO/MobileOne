import 'package:MobileOne/providers/loyalty_cards_provider.dart';
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

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 32,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: cards.length,
            itemBuilder: (BuildContext ctxt, int index) {
              List<TextEditingController> controllerList =
                  List.generate(cards.length, (index) {
                return TextEditingController();
              });
              uuidOfCard = cards.keys.toList()[index];
              return Center(
                  child: LoyaltyCardsWidget(cards.values.toList()[index],
                      uuidOfCard, controllerList[index]));
            }),
      ),
    );
  }
}
