import 'package:image_picker/image_picker.dart';

class ImageService {
  final _picker = ImagePicker();

  Future<PickedFile> pickGallery() {
    return _picker.getImage(source: ImageSource.gallery);
  }

  Future<PickedFile> pickCamera() {
    return _picker.getImage(source: ImageSource.camera);
  }
}
