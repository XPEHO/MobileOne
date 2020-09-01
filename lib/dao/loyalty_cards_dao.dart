import 'package:barcode_scan/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class LoyaltyCardsDao {
  Future<DocumentSnapshot> fetchLoyaltycards(String userUuid) =>
      FirebaseFirestore.instance.collection("loyaltycards").doc(userUuid).get();

  updateLoyaltyCards(String _name, String _cardUuid, String userUuid) async {
    await FirebaseFirestore.instance
        .collection("loyaltycards")
        .doc(userUuid)
        .set({
      _cardUuid: {
        'label': _name,
      },
    }, SetOptions(merge: true));
  }

  updateLoyaltycardsColor(
      String _color, String _cardUuid, String userUuid) async {
    await FirebaseFirestore.instance
        .collection("loyaltycards")
        .doc(userUuid)
        .set({
      _cardUuid: {
        'color': _color,
      },
    }, SetOptions(merge: true));
  }

  addLoyaltyCardsToDataBase(String _name, String _result, BarcodeFormat _format,
      String _color, String userUuid) async {
    Uuid uuid = Uuid();
    var uuidCard = uuid.v4();

    final loyaltycards = await FirebaseFirestore.instance
        .collection("loyaltycards")
        .doc(userUuid)
        .get();
    bool doesLoyaltycardExist = loyaltycards?.exists;

    if (doesLoyaltycardExist == true) {
      await FirebaseFirestore.instance
          .collection("loyaltycards")
          .doc(userUuid)
          .update({
        uuidCard: {
          'label': _name,
          'barecode': _result,
          'format': _format.toString(),
          'color': _color,
        },
      });
    } else {
      await FirebaseFirestore.instance
          .collection("loyaltycards")
          .doc(userUuid)
          .set({
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
    await FirebaseFirestore.instance
        .collection("loyaltycards")
        .doc(userUuid)
        .update({cardUuid: FieldValue.delete()});
  }
}
