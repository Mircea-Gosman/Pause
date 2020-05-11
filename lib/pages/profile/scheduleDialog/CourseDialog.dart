import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/TimeStamp.dart';
import 'package:pause_v1/user/schedule/Course.dart';



class CourseDialog extends StatefulWidget {
  bool showDeleteButton = false;
  Course course;

  CourseDialog({Key key, this.course}) : super(key: key);

  @override
  _CourseDialogState createState() => _CourseDialogState();

}

class _CourseDialogState extends State<CourseDialog> {
  StreamController<CourseDialog> innerCourseStreamController = StreamController<CourseDialog>.broadcast();
  double rightTextPosition = ScreenSize.unitWidth * 43;
  double lineLeftBound = ScreenSize.unitWidth * 25.5;

  @override
  void initState(){
    super.initState();
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    innerCourseStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    innerCourseStreamController.stream.listen((status){
      setState(() {
        status.showDeleteButton = true;
      });
    });

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

    return GestureDetector(
      onTapDown: (details) {
        if(details.globalPosition.dx < lineLeftBound + ScreenSize.unitWidth * 16.5) {
          CourseListDialogStreamHolder.of(context).reviewRequestTimeStreamController.add({'course': widget.course, 'isStart': true});
        } else if(details.globalPosition.dx > rightTextPosition + ScreenSize.unitWidth * 16.5){
          CourseListDialogStreamHolder.of(context).reviewRequestTimeStreamController.add({'course': widget.course, 'isStart': false});
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
