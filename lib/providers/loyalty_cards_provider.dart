import 'package:MobileOne/services/analytics_services.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:MobileOne/utility/database.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

class LoyaltyCardsProvider with ChangeNotifier {
  var _analytics = GetIt.I.get<AnalyticsService>();
  Future<DocumentSnapshot> get loyaltyCards {
    return Firestore.instance
        .collection("loyaltycards")
        .document(GetIt.I.get<UserService>().user.uid)
        .get();
  }

  updateLoyaltyCards(String _name, String _cardUuid) async {
    await databaseReference
        .collection("loyaltycards")
        .document(GetIt.I.get<UserService>().user.uid)
        .setData({
      _cardUuid: {
        'label': _name,
      },
    }, merge: true);
    _analytics.sendAnalyticsEvent("update_loyalty_card_name : $_name");
    notifyListeners();
  }

  addLoyaltyCardsToDataBase(String _name, String _result, BarcodeFormat _format,
      String _color) async {
    Uuid uuid = Uuid();
    var uuidCard = uuid.v4();
    bool doesDocumentExist = false;
    await databaseReference
        .collection("loyaltycards")
        .document(GetIt.I.get<UserService>().user.uid)
        .get()
        .then(
      (value) {
        doesDocumentExist = value.exists;
      },
    );

    if (doesDocumentExist == true) {
      await databaseReference
          .collection("loyaltycards")
          .document(GetIt.I.get<UserService>().user.uid)
          .updateData({
        uuidCard: {
          'label': _name,
          'barecode': _result,
          'format': _format.toString(),
          'color': _color,
        },
      });
    } else {
      await databaseReference
          .collection("loyaltycards")
          .document(GetIt.I.get<UserService>().user.uid)
          .setData({
        uuidCard: {
          'label': _name,
          'barecode': _result,
          'format': _format.toString(),
          'color': _color,
        }
      });
    }
    _analytics.sendAnalyticsEvent("add_loyalty_card");
    notifyListeners();
  }

  deleteCard(String cardUuid) async {
    await Firestore.instance
        .collection("loyaltycards")
        .document(GetIt.I.get<UserService>().user.uid)
        .updateData({cardUuid: FieldValue.delete()});
    _analytics.sendAnalyticsEvent("delete_loyalty_card");
    notifyListeners();
  }
}
