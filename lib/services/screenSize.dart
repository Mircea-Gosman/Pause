/**-----------------------------------------------------------
 * Module allowing to pick size UI elements based on
 * device screen size
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/widgets.dart';

class ScreenSize {
  static MediaQueryData _mediaQueryData;    // Device information
  static double width;                      // Device width
  static double height;                     // Device height
  static double unitWidth;                  // % width
  static double unitHeight;                 // % height
  static bool initialized = false;          // Init method usage flag

  /// Module call
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    // Establish scaling mesures
    width = _mediaQueryData.size.width;
    height = _mediaQueryData.size.height;
    unitWidth = width / 100;
    unitHeight = height / 100;

    // Initialize only once
    initialized = true;
  }
}