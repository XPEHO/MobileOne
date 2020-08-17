import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final _picker = ImagePicker();

  Future<PickedFile> pickGallery() {
    return _picker.getImage(source: ImageSource.gallery);
  }

  Future<PickedFile> pickCamera(int quality) {
    return _picker.getImage(source: ImageSource.camera, imageQuality: quality);
  }

  StorageReference uploadFile(String listUuid, File pickedImage) {
    return FirebaseStorage.instance
        .ref()
        .child('mobileone/$listUuid/${path.basename(pickedImage.path)}');
  }

  deleteFile(String listUuid, String imageName) {
    FirebaseStorage.instance
        .ref()
        .child('mobileone/$listUuid/$imageName')
        .delete();
  }
}
