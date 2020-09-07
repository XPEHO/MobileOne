import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingDao {
  setUserAppToken(String userEmail, String token) async {
    await FirebaseFirestore.instance.collection("appTokens").doc(userEmail).set(
      {"token": token},
    );
  }

  deleteUserAppToken(String userEmail) async {
    await FirebaseFirestore.instance
        .collection("appTokens")
        .doc(userEmail)
        .delete();
  }

  Future<String> getUserAppToken(String email) async {
    final token = await FirebaseFirestore.instance
        .collection("appTokens")
        .doc(email)
        .get();

    if (token.data() != null) {
      return token.data()["token"];
    } else {
      return null;
    }
  }
}
