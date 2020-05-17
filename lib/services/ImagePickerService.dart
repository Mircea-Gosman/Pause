/**-----------------------------------------------------------
 * Module allowing to pick an image from the gallery
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  /// Module call
  static Future<File> pickImage() async {
    return  ImagePicker.pickImage(source: ImageSource.gallery);
  }
}