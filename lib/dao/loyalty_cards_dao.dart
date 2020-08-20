import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LoyaltyCardsDao {
  Future<DocumentSnapshot> fetchLoyaltycards(String userUuid) =>
      Firestore.instance.collection("loyaltycards").document(userUuid).get();

  updateLoyaltyCards(String _name, String _cardUuid, String userUuid) async {
    await Firestore.instance
        .collection("loyaltycards")
        .document(userUuid)
        .setData({
      _cardUuid: {
        'label': _name,
      },
    }, merge: true);
  }

  addLoyaltyCardsToDataBase(String _name, String _result, BarcodeFormat _format,
      String _color, String userUuid) async {
    Uuid uuid = Uuid();
    var uuidCard = uuid.v4();

    final loyaltycards = await Firestore.instance
        .collection("loyaltycards")
        .document(userUuid)
        .get();
    bool doesLoyaltycardExist = loyaltycards?.exists;

    if (doesLoyaltycardExist == true) {
      await Firestore.instance
          .collection("loyaltycards")
          .document(userUuid)
          .updateData({
        uuidCard: {
          'label': _name,
          'barecode': _result,
          'format': _format.toString(),
          'color': _color,
        },
      });
    } else {
      await Firestore.instance
          .collection("loyaltycards")
          .document(userUuid)
          .setData({
        uuidCard: {
          'label': _name,
          'barecode': _result,
          'format': _format.toString(),
          'color': _color,
        }
      });
    }
  }

  deleteCard(String cardUuid, String userUuid) async {
    await Firestore.instance
        .collection("loyaltycards")
        .document(userUuid)
        .updateData({cardUuid: FieldValue.delete()});
  }
}
