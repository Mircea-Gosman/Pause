/**-----------------------------------------------------------
 * A line of the CourseListDialog widget, representing
 * a user's course
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/TimeStamp.dart';
import 'package:pause_v1/user/schedule/Course.dart';


/// CourseDialog parent Widget
class CourseDialog extends StatefulWidget {
  bool showDeleteButton = false;    // Whether to show the delete button or not
  Course course;                    // Source course

  /// Initializer
  CourseDialog({Key key, this.course}) : super(key: key);

  /// Create state
  @override
  _CourseDialogState createState() => _CourseDialogState();

}

/// CourseDialog state
class _CourseDialogState extends State<CourseDialog> {
  StreamController<CourseDialog> innerCourseStreamController = StreamController<CourseDialog>.broadcast();  // Callback to show the course delete button
  double rightTextPosition = ScreenSize.unitWidth * 43;                                                     // Right TimeStamp position X
  double lineLeftBound = ScreenSize.unitWidth * 25.5;                                                       // Middle line button position X


  /// Dispose of propietary stream controller
  @override
  void dispose() {
    innerCourseStreamController.close();
    super.dispose();
  }

  /// Build the UI
  @override
  Widget build(BuildContext context) {
    // Listen to innerCourseStream to be notified when the the delete
    // button should appear
    innerCourseStreamController.stream.listen((status){
      setState(() {
        status.showDeleteButton = true;
      });
    });

    /// Build list of children
    List<Widget> buildChildren() {
      List<Widget>  builder = [
        // Displayed TimeStamps
        TimeStamp(source: {'course': widget.course, 'time': widget.course.startTime, 'isStart': true}),
        TimeStamp(source: {'course': widget.course, 'time': widget.course.endTime, 'isStart': false}, indent: rightTextPosition),

        // Line between the two TimeStamps
        Positioned(
          top: ScreenSize.unitHeight*2,
          left: lineLeftBound,
          child: Container(
            height: ScreenSize.unitHeight * 1, // 1
            width: ScreenSize.unitWidth * 15,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.black)),
              color: Colors.black,
              padding: EdgeInsets.all(8.0),
              onPressed: () {
                //TODO
              },
            ),
          ),
        ),
      ];

      // Delete button if applicable
      if(widget.showDeleteButton) {
        builder.add(
          Positioned(
            left: ScreenSize.unitWidth * 28,

            child: CircleAvatar(
              radius: ScreenSize.unitWidth * 5, // 5 3
              backgroundColor: Colors.black,
              child: SizedBox.expand(
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 5,
                  ),
                  onPressed: () {
                    CourseListDialogStreamHolder.of(context).outterCourseStreamController.add(widget);
                  },
                ),
              ),
            ),
          ),
        );
      }

      return builder;
    }

    /// Add list of children to the widget tree under a tap detector
    return GestureDetector(
      onTapDown: (details) {
        // Monitor tap on left timeStamp
        if(details.globalPosition.dx < lineLeftBound + ScreenSize.unitWidth * 16.5) {
          CourseListDialogStreamHolder.of(context).reviewRequestTimeStreamController.add({'course': widget.course, 'isStart': true});
        // Monitor tap on right timeStamp
        } else if(details.globalPosition.dx > rightTextPosition + ScreenSize.unitWidth * 16.5){
          CourseListDialogStreamHolder.of(context).reviewRequestTimeStreamController.add({'course': widget.course, 'isStart': false});
        // Monitor tap on middle line button
        } else {
          innerCourseStreamController.add(widget);
        }
      },
      child:Stack(
        children: buildChildren()
      )
    );


  }
}
