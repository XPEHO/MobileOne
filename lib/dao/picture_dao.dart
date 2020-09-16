import 'package:MobileOne/data/user_picture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PictureDao {
  setUserPicture(String fileUrl, String _imageName, String userUid) async {
    await FirebaseFirestore.instance.collection("userPicture").doc(userUid).set(
      {
        "path": fileUrl,
        "name": _imageName,
      },
    );
  }

  Future<DocumentSnapshot> fetchUserPicture(String userUid) async {
    return await FirebaseFirestore.instance
        .collection("userPicture")
        .doc(userUid)
        .get();
  }

  deleteUserPicture(String userUid, UserPicture picture) {
    FirebaseStorage.instance
        .ref()
        .child('mobileone/usersPictures/$userUid/${picture.name}')
        .delete();
  }
}
