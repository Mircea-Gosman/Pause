import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/services/screenSize.dart';

import 'package:pause_v1/pages/profile/scheduleDialog/CourseDialog.dart';
import 'package:pause_v1/user/schedule/Course.dart';
import 'package:intl/intl.dart';

class CourseListDialog extends StatefulWidget {
  List<Course> courses;
  List<CourseDialog> courseWidgets;

  CourseListDialog(List<Course> courses){
    this.courses = courses;
    buildCourseListFromUser();
  }

  @override
  _CourseListDialogState createState() => _CourseListDialogState();


  void buildCourseListFromUser(){
    courseWidgets = [];
    for(Course course in courses){
      courseWidgets.add(
        CourseDialog(
          course: course,
        ),
      );
    }
  }

}

class _CourseListDialogState extends State<CourseListDialog> { // need to be built in state, not in parent
  Map reviewedCourse;

  _CourseListDialogState(){
    // Build course widgets from user courses
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    CourseListDialogStreamHolder.of(context).outterCourseStreamController.stream.listen((expiredWidget){
      setState(() {
        widget.courseWidgets = List.from(widget.courseWidgets)..remove(expiredWidget); // ListView will only update if array of reference changes, flutter is based on immutable objects**
        widget.courses.remove(expiredWidget.course);
      });
    });
    CourseListDialogStreamHolder.of(context).reviewRequestTimeStreamController.stream.listen((sourceWidgetCourse){
      setState(() {
        reviewedCourse = sourceWidgetCourse;
      });
    });

    void reviewCourse(DateTime newTime) {
      print('reviewedCourse:');
      print(reviewedCourse['course'].startTime);
      print('Courses:');
      for (Course course in widget.courses) {
        print(course.startTime);

        if (course == reviewedCourse['course']){
          String newTimeString = DateFormat('Hm').format(newTime);
          if(reviewedCourse['isStart']){
            course.startTime = newTimeString;
          } else {
            course.endTime = newTimeString;
          }

          // Notify TimeStamp widget for UI change
          CourseListDialogStreamHolder.of(context).reviewTimeStreamController.add({'course': course, 'time': newTimeString, 'isStart': reviewedCourse['isStart']});
          break;
        }
      }
    }

    DateTime initializeDateTime(){
      DateTime datetime = DateTime.now();
      String time = reviewedCourse['course'].startTime;

      if(!reviewedCourse['isStart']){
        time = reviewedCourse['course'].endTime;
      }

      if(!reviewedCourse['course'].startTime.contains('?')){
        datetime = DateFormat('Hm').parse(time);
      }

      return datetime;
    }

    List<Widget> buildChildren() {
      List<Widget> builder = [];

      if (widget.courseWidgets.isNotEmpty) {
        builder.add(
          Positioned(
            top: ScreenSize.unitHeight * 30,
            left: ScreenSize.unitWidth * 16.5,
            width: ScreenSize.unitWidth * 67 ,
            height:ScreenSize.unitHeight * 45,

            child: ConstrainedBox(
              constraints: new BoxConstraints(
                maxHeight: ScreenSize.unitHeight*50,
              ),

              child: new ListView(
                itemExtent: ScreenSize.unitHeight*10,
                children: widget.courseWidgets,
              ),
            ),
          ),
        );

        if (reviewedCourse != null) {
          builder.add(
            Stack(
              children: <Widget>[
                // Time Picker
                Positioned(
                  top: ScreenSize.unitHeight * 65,
                  left: ScreenSize.unitWidth * 39,
                  child: SizedBox(
                    width: ScreenSize.unitWidth * 22,
                    height: ScreenSize.unitHeight * 15,

                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: initializeDateTime(),
                      backgroundColor: Colors.transparent,
                      onDateTimeChanged: (DateTime newTime) {
                        reviewCourse(newTime);
                      },
                    ),
                  ),
                ),
                // Confirmation button
                Positioned(
                  top: ScreenSize.unitHeight * 80,
                  left: ScreenSize.unitWidth * 45,

                  child: CircleAvatar(
                    radius: ScreenSize.unitWidth * 5,
                    backgroundColor: Colors.black,
                    child: SizedBox.expand(
                      child: IconButton(
                        padding: EdgeInsets.all(0.0),
                        icon: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: ScreenSize.unitWidth * 5,
                        ),
                        onPressed: () {
                          setState(() {
                            reviewedCourse = null;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )
          );
        }

      } else {
        builder.add(
          Positioned(
            top: ScreenSize.unitHeight * 45,
            left: ScreenSize.unitWidth * 35,

            child: Text(
              'Day off?',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle( fontWeight: FontWeight.bold, fontSize: ScreenSize.unitHeight * 5),
            ),
          ),
        );
      }
      return builder;
    }

    return Stack(
        children: buildChildren(),
    );

  }
}
