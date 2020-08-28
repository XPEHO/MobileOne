import 'package:MobileOne/services/loyalty_cards_service.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoyaltyCardsProvider with ChangeNotifier {
  LoyaltyCardsService loyaltycardsService = GetIt.I.get<LoyaltyCardsService>();

  updateLoyaltyCards(String _name, String _cardUuid) async {
    await loyaltycardsService.updateLoyaltyCards(_name, _cardUuid);

    notifyListeners();
  }

  addLoyaltyCardsToDataBase(String _name, String _result, BarcodeFormat _format,
      String _color) async {
    await loyaltycardsService.addLoyaltyCardsToDataBase(
        _name, _result, _format, _color);
    notifyListeners();
  }

  updateLoyaltycardsColor(
      String _color, String _cardUuid, String userUuid) async {
    await loyaltycardsService.updateLoyaltycardsColor(
        _color, _cardUuid, userUuid);
    notifyListeners();
  }

  deleteCard(String cardUuid) async {
    await loyaltycardsService.deleteCard(cardUuid);
    notifyListeners();
  }

  Map<String, dynamic> get allLoyaltycards {
    Map<String, dynamic> loyaltycards = loyaltycardsService.getLoyaltycards();
    if (loyaltycards.isEmpty) {
      loyaltycardsService
          .fetchLoyaltycards()
          .whenComplete(() => notifyListeners());
      return loyaltycards;
    }
    return loyaltycards;
  }
}
