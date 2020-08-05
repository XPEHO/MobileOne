import 'package:flutter/material.dart';

class CardArguments {
  Map<String, dynamic> cards;
  Color colorOfCard;

  CardArguments(this.cards, this.colorOfCard);
}

class ShareArguments {
  var previousList;
  bool isOnlyOneStep;
  ShareArguments({this.previousList, this.isOnlyOneStep});
}

class ItemArguments {
  String buttonName;
  String listUuid;
  String itemUuid;
  ItemArguments({this.buttonName, this.listUuid, this.itemUuid});
}
