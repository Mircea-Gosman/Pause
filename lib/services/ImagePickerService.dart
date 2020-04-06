import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {

  // TODO: If needs arrise, make this into an instance method
  static Future<File> pickImage() async {
    return  ImagePicker.pickImage(source: ImageSource.gallery);
  }
}