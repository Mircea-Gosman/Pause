/**-----------------------------------------------------------
 * Dialog allowing user to alter the server's
 * analyzis of the schedule's picture
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialog.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:pause_v1/user/schedule/Day.dart';
import 'package:provider/provider.dart';
import 'package:align_positioned/align_positioned.dart';

/// CorrectionDialog parent widget
class CorrectionDialog extends StatefulWidget {
  final StreamController<bool> scheduleStreamController;  // Callback to close parent widget
  final StreamController<bool> dialogStreamController;    // Callback to close this widget

  /// Initializer
  CorrectionDialog({Key key,  this.scheduleStreamController, this.dialogStreamController}) : super(key: key);

  /// Create state
  @override
  _CorrectionDialogState createState() => _CorrectionDialogState();
}

/// CorrectionDialog state
class _CorrectionDialogState extends State<CorrectionDialog> with SingleTickerProviderStateMixin {
  List<Day> days;                                                                                 // User's schedule's days
  int dayIndex = 0;                                                                               // Current progression in the dialog
  bool backwards = false;                                                                         // Whether progression should move backwards
  Animation<double> animation;                                                                    // Fade animation
  AnimationController _controller;                                                                // Fade animation controller
  Duration animationDuration = Duration(milliseconds: 500);                                       // Fade animation duration

  /// Initialize the state
  @override
  void initState() {
    super.initState();

    // Access user data
    days =  Provider.of<Server>(context, listen: false).user.schedule.days;

    // Animation controller setup
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

        // Dont fade-in on end of dialog
        if (dayIndex != days.length) {
          // Fade in animation
          _controller.reverse();
        }
      }
    });

    // Animation setup
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

  /// Dispose of the animation controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Run the fade-out animation
  void runOpacityAnimation(){
    _controller.forward();
  }

  /// Build the UI
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Day title
        AlignPositioned(
          alignment: Alignment.topCenter,
          dy:  ScreenSize.unitHeight * 20,

          child: FadeTransition(
            opacity: animation,
            child: Text(
                days[dayIndex].title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenSize.unitHeight * 8),
              ),
          ),
        ),
        // Course List
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
                    // Allow for backwards navigation if not the first day
                    if(dayIndex != 0){
                      backwards = true;
                      runOpacityAnimation();
                    } else {
                      // Close all dialogs
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
