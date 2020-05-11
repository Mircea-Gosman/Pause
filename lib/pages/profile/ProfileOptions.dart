import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/services/screenSize.dart';

import '../../Services/LocationService.dart';


// Profile page buttons set
class ProfileOptions extends StatefulWidget{
  StreamController<bool> scheduleFlow = StreamController<bool>.broadcast();

  ProfileOptions({Key key}) : super(key: key);

  @override
  _ProfileOptionsState createState() => _ProfileOptionsState();
}

class _ProfileOptionsState extends State<ProfileOptions> {
  final Duration _duration = Duration(milliseconds: 300);
  final Cubic _curveForm = Curves.easeOut;
  final double _initialY = ScreenSize.unitHeight * 73;
  final double _initialRightX = ScreenSize.unitWidth * 68;
  final double _initialLeftX = ScreenSize.unitWidth * 9;
  double movementY = 0;
  double rightMovement = 0;
  double leftMovement = 0;
  bool _isOnScreen = false;

  @override
  void initState(){
    super.initState();
    widget.scheduleFlow.stream.listen((status){
      setState(() {
        _isOnScreen = !_isOnScreen;

        if (status) {
          movementY =  ScreenSize.unitHeight * 100 - _initialY - 10; // Put off-screen, remove -10 in final
          rightMovement = ScreenSize.unitWidth * 76 - _initialRightX;
          leftMovement = _initialLeftX;
        } else {
          movementY = 0;
          rightMovement = 0;
          leftMovement = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          // Add Schedule Button
          AnimatedPositioned(
            duration: _duration,
            curve: _curveForm,
            top: _initialY + movementY + ScreenSize.unitHeight * 7,
            left: ScreenSize.unitWidth * 35,

            child: CircleAvatar(
              radius: ScreenSize.unitWidth * 15,
              backgroundColor: Colors.black,
              child: SizedBox.expand(
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 18,
                  ),
                  onPressed: () {
                    _retractUI();
                  },
                ),
              ),
            ),
          ),
          // Geolocalisation button
          AnimatedPositioned(
            duration: _duration,
            curve: _curveForm,
            top: _initialY + movementY,
            left: _initialLeftX - leftMovement,
            //width: ScreenSize.unitWidth * 25,
            //height: 85,
            child: CircleAvatar(
              radius: ScreenSize.unitWidth * 12,
              backgroundColor: Colors.black,
              child: SizedBox.expand(
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 12,
                  ),
                  onPressed: () {
                    LocationService.setLocationAvailable();
                    // TODO

                  },
                  ),
                ),
            ),
          ),
          // Do not disturb button
          AnimatedPositioned(
            duration: _duration,
            curve: _curveForm,
            top: _initialY + movementY,
            left: _initialRightX + rightMovement,
            child: CircleAvatar(
              radius: ScreenSize.unitWidth * 12,
              backgroundColor: Colors.black,
              child: SizedBox.expand(
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.do_not_disturb_on,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 12,
                  ),
                  onPressed: () {
                    // TODO
                  },
                ),
              ),
            ),
          )
      ],
    );
  }

  void _retractUI() {
      if (_isOnScreen) {
          widget.scheduleFlow.add(true);
        } else {
          widget.scheduleFlow.add(false);
        }
  }
}
