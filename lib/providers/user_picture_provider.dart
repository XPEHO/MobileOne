import 'dart:io';

import 'package:MobileOne/data/user_picture.dart';
import 'package:MobileOne/services/picture_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserPictureProvider with ChangeNotifier {
  var pictureService = GetIt.I.get<PictureService>();

  UserPicture getUserPicture() {
    UserPicture userPicture = pictureService.getUserPicture();
    if (userPicture == null) {
      pictureService.fetchUserPicture().then((value) => notifyListeners());
    }
    return userPicture;
  }

  StorageReference getStorageRef(File pickedImage) {
    return pictureService.getStorageRef(pickedImage);
  }

  StorageUploadTask uploadItemPicture(
      StorageReference storageReference, File pickedImage) {
    return pictureService.uploadItemPicture(storageReference, pickedImage);
  }

  setUserPicture(String fileUrl) async {
    await pictureService.setUserPicture(fileUrl);
    notifyListeners();
  }

  deleteUserPicture() {
    pictureService.deleteUserPicture();
  }

  flushPicture() {
    pictureService.flush();
  }
}
