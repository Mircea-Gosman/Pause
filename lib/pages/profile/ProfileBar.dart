/**-----------------------------------------------------------
 * Custom App bar
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:provider/provider.dart';

import '../../painters/ProfileBarPainter.dart';

/// ProfileBar parent widget
class ProfileBar extends StatefulWidget {
  Stream scheduleStream;  // Upload Dialog stream
  bool toggle = true;     // Whether or not the widget can be retracted manually

  /// Initializer
  ProfileBar({Key key}) : super(key: key);

  /// Initializer using pre-built Upload Dialog stream
  ProfileBar.fromOptions(Stream scheduleStream){
    this.scheduleStream = scheduleStream;
    this.toggle = false; // If options are present => profilePage => toggle off
  }

  /// Create state
  @override
  _ProfileBarState createState() => _ProfileBarState();
}

/// ProfileBar state
class _ProfileBarState extends State<ProfileBar> with SingleTickerProviderStateMixin {
  final _gestureSensitivity = -5;   // GestureDetector activity threshold
  Animation<double> animation;      // Retraction animation
  AnimationController _controller;  // Retractiona animation controller

  /// Initialize state
  @override
  void initState() {
    super.initState();

    // Define animation controller
    _controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);

    // Define animation
    animation = Tween<double>(begin: 0, end: ScreenSize.unitHeight * -22).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Retract on options bar button click
    if (widget.scheduleStream != null){
      // Instantiate upload schedule listener
      widget.scheduleStream.listen((status){
        // bool status : button click engaged/disengaged
        if (status) {
          _retractUI();
        } else {
          _expandUI();
        }
      });
    }
  }

  // Disose of the animation controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Retract the UI as per animation
  void _retractUI() {
    _controller.forward();
  }

  // Expand the UI as per animation
  void _expandUI() {
    _controller.reverse();
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Detect swipes
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (widget.toggle) {
              if(details.delta.dy < _gestureSensitivity) {
                _retractUI();
              } else if( details.delta.dy > _gestureSensitivity * -1){
                _expandUI();
              }
            }
          },
          // Draw UI
          child: CustomPaint(
            willChange: true,
            painter: ProfileBarPainter(animation), // Draw background
            child:  Container(
              width: ScreenSize.unitWidth * 100,
              height: ScreenSize.unitHeight * 45,
              child: Stack(
                children: <Widget>[
                  // Profile button
                  Positioned(
                    top: ScreenSize.unitHeight * 10 + animation.value + animation.value/2,
                    left: ScreenSize.unitWidth * 36,
                    child: FlatButton(
                      padding: EdgeInsets.all(0.0),
                      child: CircleAvatar(
                          radius: ScreenSize.unitWidth * 14,
                          backgroundImage: CachedNetworkImageProvider(
                              Provider.of<Server>(context, listen: false).user.profilePictureURL
                          ),
                          backgroundColor: Colors.transparent
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/Profile');
                      },
                    ),
                  ),
                  // Settings button
                  Positioned(
                    top: ScreenSize.unitHeight * 21 + animation.value + animation.value/2,
                    left: ScreenSize.unitWidth * 60,
                    child:  IconButton(
                      color: Colors.white,
                      onPressed: (){
                        // TODO
                        print('what');
                      },
                      icon: Icon(Icons.settings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// For sizing place this custom class: https://medium.com/flutter-community/flutter-effectively-scale-ui-according-to-different-screen-sizes-2cb7c115ea0a
// in a provider at app launch
// & just size + position things by multiplying fractions of height/width