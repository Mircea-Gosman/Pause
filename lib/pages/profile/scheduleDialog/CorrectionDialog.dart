import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialog.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:pause_v1/user/schedule/Day.dart';
import 'package:pause_v1/user/schedule/Course.dart';
import 'package:provider/provider.dart';
import 'package:align_positioned/align_positioned.dart';

class CorrectionDialog extends StatefulWidget {
  final StreamController<bool> scheduleStreamController;
  final StreamController<bool> dialogStreamController;
  CorrectionDialog({Key key,  this.scheduleStreamController, this.dialogStreamController}) : super(key: key);

  @override
  _CorrectionDialogState createState() => _CorrectionDialogState();
}


class _CorrectionDialogState extends State<CorrectionDialog> with SingleTickerProviderStateMixin {
  List<Day> days;
  int dayIndex = 0;
  bool backwards = false;
  Animation<double> animation;
  AnimationController _controller;
  Duration animationDuration = Duration(milliseconds: 500);
  StreamController<List<Course>> newCoursesStream = StreamController<List<Course>>.broadcast();

  @override
  void initState() {
    super.initState();

    // Access user data
    days =  Provider.of<Server>(context, listen: false).user.schedule.days;

    // Animation setup
    _controller = AnimationController(
        duration: animationDuration, vsync: this);

    // Allow single repeat
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Move to next day
        if(backwards){
          dayIndex --;
          backwards = false;
        } else {
          dayIndex ++;
        }

        if (dayIndex != days.length) {
          newCoursesStream.add(days[dayIndex].courses);

          // Fade in animation
          _controller.reverse();
        }
      }
    });
    
    animation =
    Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut
        )
      )..addListener(() {
        setState(() {

        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void runOpacityAnimation(){
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Upload text
        AlignPositioned(
          alignment: Alignment.topCenter,
          dy:  ScreenSize.unitHeight * 20,
          //top: ScreenSize.unitHeight * 15,
          //left: ScreenSize.unitWidth * 25,

          child: FadeTransition(
            opacity: animation,
            child: Text(
                days[dayIndex].title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenSize.unitHeight * 8),
              ),
          ),
        ),
        Positioned(
          child: FadeTransition(
            opacity: animation,
            child: CourseListDialogStreamHolder(
                child: CourseListDialog(days[dayIndex].courses)
            )
          ),
        ),
        // Back button
        Positioned(
          top: ScreenSize.unitHeight * 80,
          left: ScreenSize.unitWidth * 20,

          child: CircleAvatar(
            radius: ScreenSize.unitWidth * 11,
            backgroundColor: Colors.black,
            child: SizedBox.expand(
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: dayIndex == 0 ? Icon(
                    Icons.close,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 14,
                  ) : Icon(
                    Icons.navigate_before,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 14,
                  ),
                  onPressed: () {
                    // TODO
                    if(dayIndex != 0){
                      backwards = true;
                      runOpacityAnimation();
                    } else {
                      widget.scheduleStreamController.add(false);
                      widget.dialogStreamController.add(true);
                    }
                  },
                ),
              ),
          ),
        ),

        // Next day button
        Positioned(
          top: ScreenSize.unitHeight * 80,
          left: ScreenSize.unitWidth * 60,

          child: CircleAvatar(
            radius: ScreenSize.unitWidth * 11,
            backgroundColor: Colors.black,
            child: SizedBox.expand(
              child: IconButton(
                padding: EdgeInsets.all(0.0),
                icon: days.length - 1 == dayIndex ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: ScreenSize.unitWidth * 14,
                ) : Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                  size: ScreenSize.unitWidth * 14,
                ),
                onPressed: () {
                    // TODO
                    if(days.length - 1 != dayIndex){
                      runOpacityAnimation();
                    } else {
                      widget.scheduleStreamController.add(false);
                      widget.dialogStreamController.add(true);
                    }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
