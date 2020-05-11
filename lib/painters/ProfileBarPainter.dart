import 'package:flutter/material.dart';
import 'package:pause_v1/services/screenSize.dart';


// Profile bar background drawing
class ProfileBarPainter extends CustomPainter {
  final Animation<double> _animation;

  ProfileBarPainter(this._animation) : super(repaint: _animation);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    bool retracted = false;
    double heightOffsetA = _animation.value;
    double heightOffsetB = _animation.value * 10/22;


    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;

    var path = Path();

    if(retracted){
      heightOffsetA = ScreenSize.unitHeight * -22;
      heightOffsetB = ScreenSize.unitHeight * -5;
    }

    path.moveTo(0, ScreenSize.unitHeight * 25 + heightOffsetA);
    path.quadraticBezierTo(
        ScreenSize.unitWidth * 50, ScreenSize.unitHeight * 40 + heightOffsetA + heightOffsetB, size.width, ScreenSize.unitHeight * 25 + heightOffsetA);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}