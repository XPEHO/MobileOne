import 'package:MobileOne/dao/loyalty_cards_dao.dart';

import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get_it/get_it.dart';

class LoyaltyCardsService {
  LoyaltyCardsDao dao = GetIt.I.get<LoyaltyCardsDao>();
  UserService userService = GetIt.I.get<UserService>();
  AnalyticsService _analytics = GetIt.I.get<AnalyticsService>();

  Map<String, dynamic> _loyaltycards = {};

  getLoyaltycards() => _loyaltycards;

  Future<Map<String, dynamic>> fetchLoyaltycards() async {
    DocumentSnapshot loyaltycards =
        await dao.fetchLoyaltycards(userService.user.uid);
    if (loyaltycards?.data == null) {
      return Map();
    } else {
      _loyaltycards = loyaltycards.data;
      return _loyaltycards ?? Map();
    }
  }

  updateLoyaltyCards(String _name, String _cardUuid) async {
    await dao.updateLoyaltyCards(_name, _cardUuid, userService.user.uid);
    _analytics.sendAnalyticsEvent("update_loyalty_card_name : $_name");
    _loyaltycards = await fetchLoyaltycards();
  }

  addLoyaltyCardsToDataBase(String _name, String _result, BarcodeFormat _format,
      String _color) async {
    await dao.addLoyaltyCardsToDataBase(
        _name, _result, _format, _color, userService.user.uid);
    _loyaltycards = await fetchLoyaltycards();
    _analytics.sendAnalyticsEvent("add_loyalty_card");
  }

  updateLoyaltycardsColor(
      String _color, String _cardUuid, String userUuid) async {
    await dao.updateLoyaltycardsColor(_color, _cardUuid, userUuid);
    _loyaltycards = {};
  }

  deleteCard(String cardUuid) async {
    await dao.deleteCard(cardUuid, userService.user.uid);
    _loyaltycards = await fetchLoyaltycards();
    _analytics.sendAnalyticsEvent("delete_loyalty_card");
  }

  int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
