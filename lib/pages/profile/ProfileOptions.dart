/**-----------------------------------------------------------
 * Lower screen buttons in the ProfilePage
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/services/screenSize.dart';

import '../../Services/LocationService.dart';


/// ProfileOptions parent widget
class ProfileOptions extends StatefulWidget{
  // Callback reference for opening/closing the schedule upload dialog
  StreamController<bool> scheduleFlow = StreamController<bool>.broadcast();

  /// Initializer
  ProfileOptions({Key key}) : super(key: key);

  @override
  _ProfileOptionsState createState() => _ProfileOptionsState();
}

/// ProfileOptions state
class _ProfileOptionsState extends State<ProfileOptions> {
  final Duration _duration = Duration(milliseconds: 300);  // Animation duration
  final Cubic _curveForm = Curves.easeOut;                 // Animation smoothness
  final double _initialY = ScreenSize.unitHeight * 73;     // Initial position Y
  final double _initialRightX = ScreenSize.unitWidth * 68; // Initial right btn X
  final double _initialLeftX = ScreenSize.unitWidth * 9;   // Initial left btn X
  double movementY = 0;                                    // Animation position offset Y
  double rightMovement = 0;                                // Anim. right btn position offset X
  double leftMovement = 0;                                 // Anim. left btn position offset X
  bool _isOnScreen = false;                                // Upload dialog on/off

  /// State initializer
  @override
  void initState(){
    super.initState();

    // Instantiate upload dialog stream listener
    widget.scheduleFlow.stream.listen((status){
      // bool status : Upload dialog button engaged/disengaged

      setState(() {
        // Inverse dialog state
        _isOnScreen = !_isOnScreen;

        // Retract dialog based on button click
        if (status) {
          movementY =  ScreenSize.unitHeight * 100 - _initialY - 10;
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

  /// Build UI
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          // Schedule Button
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

  /// Trigger dialog appearance callback
  void _retractUI() {
      // Close dialog if open, open dialog if closed
      if (_isOnScreen) {
          widget.scheduleFlow.add(true);
        } else {
          widget.scheduleFlow.add(false);
        }
  }
}
