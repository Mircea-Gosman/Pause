import 'package:flutter/widgets.dart';

class ScreenSize {
  static MediaQueryData _mediaQueryData;
  static double width;
  static double height;
  static double unitWidth;
  static double unitHeight;
  static bool initialized = false;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    width = _mediaQueryData.size.width;
    height = _mediaQueryData.size.height;
    unitWidth = width / 100;
    unitHeight = height / 100;
    initialized = true;
  }
}