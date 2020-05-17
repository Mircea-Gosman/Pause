/**-----------------------------------------------------------
 * Background drawing of the profile bar widget
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';
import 'package:pause_v1/services/screenSize.dart';

class ProfileBarPainter extends CustomPainter {
  final Animation<double> _animation;   // Retraction animation

  /// Initializer
  ProfileBarPainter(this._animation) : super(repaint: _animation);

  /// Custom painter widget
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();                              // Painter
    var path = Path();                                // Outline
    bool retracted = false;                           // Retraction status
    double heightOffsetA = _animation.value;          // Edge retraction offset
    double heightOffsetB = _animation.value * 10/22;  // Peak retraction offset

    // Define style properties
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;

    // Fully retracted form
    if(retracted){
      heightOffsetA = ScreenSize.unitHeight * -22;
      heightOffsetB = ScreenSize.unitHeight * -5;
    }

    // Build the background's shape
    path.moveTo(0, ScreenSize.unitHeight * 25 + heightOffsetA);
    path.quadraticBezierTo(
        ScreenSize.unitWidth * 50, ScreenSize.unitHeight * 40 + heightOffsetA + heightOffsetB, size.width, ScreenSize.unitHeight * 25 + heightOffsetA);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  /// Allow for painter drawing updates for the animation
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}