import 'dart:io';

import 'package:MobileOne/dao/picture_dao.dart';
import 'package:MobileOne/data/user_picture.dart';
import 'package:MobileOne/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

class PictureService {
  var userService = GetIt.I.get<UserService>();
  var dao = GetIt.I.get<PictureDao>();

  UserPicture picture;
  String _imageName;

  flush() {
    picture = null;
  }

  UserPicture getUserPicture() => picture;

  Future<void> fetchUserPicture() async {
    DocumentSnapshot snap = await dao.fetchUserPicture(userService.user.uid);

    if (snap.data() != null) {
      picture = UserPicture.fromMap(snap.data());
    } else {
      picture = UserPicture.fromMap({"path": "", "name": ""});
    }
  }

  StorageReference getStorageRef(File pickedImage) {
    _imageName = path.basename(pickedImage.path);
    return uploadFile(userService.user.uid, _imageName);
  }

  StorageUploadTask uploadItemPicture(
      StorageReference storageReference, File pickedImage) {
    return storageReference.putFile(pickedImage);
  }

  StorageReference uploadFile(String userUid, String imagePath) {
    return FirebaseStorage.instance
        .ref()
        .child('mobileone/usersPictures/$userUid/$imagePath');
  }

  setUserPicture(String fileUrl) async {
    await dao.setUserPicture(fileUrl, _imageName, userService.user.uid);
    flush();
  }

  deleteUserPicture() {
    if (picture != null && picture.name != null && picture.name.isNotEmpty) {
      dao.deleteUserPicture(userService.user.uid, picture);
    }
  }
}
