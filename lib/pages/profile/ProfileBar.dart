import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:provider/provider.dart';

import '../../painters/ProfileBarPainter.dart';

// App Bar
class ProfileBar extends StatefulWidget {
  Stream scheduleStream;
  bool toggle = true;

  ProfileBar({Key key}) : super(key: key);

  ProfileBar.fromOptions(Stream scheduleStream){
    this.scheduleStream = scheduleStream;
    this.toggle = false; // If options are present => profilePage => toggle off
  }

  @override
  _ProfileBarState createState() => _ProfileBarState();
}

class _ProfileBarState extends State<ProfileBar> with SingleTickerProviderStateMixin {
  final _gestureSensitivity = -5;

  Animation<double> animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    animation = Tween<double>(begin: 0, end: ScreenSize.unitHeight * -22).animate(_controller)
      ..addListener(() {
        setState(() {
         // The state that has changed here is the animation object’s value.
        });
      });

    // Retract on options bar button click
    if (widget.scheduleStream != null){
      widget.scheduleStream.listen((status){
        if (status) {
          _retractUI();
        } else {
          _expandUI();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _retractUI() {
    _controller.forward();
  }

  void _expandUI() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: CustomPaint(
            willChange: true,
            painter: ProfileBarPainter(animation),
            child:  Container(
              width: ScreenSize.unitWidth * 100,
              height: ScreenSize.unitHeight * 45,
              child: Stack(
                children: <Widget>[
                  // Profile
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
                  Positioned(
                    top: ScreenSize.unitHeight * 21 + animation.value + animation.value/2,
                    left: ScreenSize.unitWidth * 60,
                    child:  IconButton(
                      color: Colors.white,
                      //shape: CircleBorder(),
                      //textColor: Colors.white,
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