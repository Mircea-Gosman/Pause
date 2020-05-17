/**-----------------------------------------------------------
 * Scrolling list of widgets representing a day's courses
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/services/screenSize.dart';

import 'package:pause_v1/pages/profile/scheduleDialog/CourseDialog.dart';
import 'package:pause_v1/user/schedule/Course.dart';
import 'package:intl/intl.dart';

/// CourseListDialog parent widget
class CourseListDialog extends StatefulWidget {
  List<Course> courses;               // List of courses to source from
  List<CourseDialog> courseWidgets;   // List of widgets to display

  /// Initializer
  CourseListDialog(List<Course> courses){
    this.courses = courses;
    buildCourseListFromUser();
  }

  /// Create state
  @override
  _CourseListDialogState createState() => _CourseListDialogState();

  /// Create the widgets from the course list
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

/// CourseListDialog State
class _CourseListDialogState extends State<CourseListDialog> {
  // Map allowing for TimeStamp content updates
  Map reviewedCourse;

  /// Build the UI
  @override
  Widget build(BuildContext context) {
    // Listen to outer. stream to be notified of WidgetCourses removal
    CourseListDialogStreamHolder.of(context).outterCourseStreamController.stream.listen((expiredWidget){
      setState(() {
        widget.courseWidgets = List.from(widget.courseWidgets)..remove(expiredWidget); // ListView will only update if array of reference changes, flutter is based on immutable objects**
        widget.courses.remove(expiredWidget.course);
      });
    });

    // Listen to requestTimestream to be notified of WidgetCourses content updates
    CourseListDialogStreamHolder.of(context).reviewRequestTimeStreamController.stream.listen((sourceWidgetCourse){
      setState(() {
        reviewedCourse = sourceWidgetCourse;
      });
    });

    /// Send notification of course content update
    /// to corresponding TimeStamp widget
    void reviewCourse(DateTime newTime) {
      // Find reviewed course among courses
      for (Course course in widget.courses) {

        if (course == reviewedCourse['course']){
          String newTimeString = DateFormat('Hm').format(newTime);

          // Change the course's corresponding timestamp
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

    /// Convert time data from String to DateTime
    DateTime initializeDateTime(){
      DateTime datetime = DateTime.now();
      String time = reviewedCourse['course'].startTime;

      // First figure out which timeStamp is being reviewed
      if(!reviewedCourse['isStart']){
        time = reviewedCourse['course'].endTime;
      }

      // Then parse the timeStamp's content
      if(!reviewedCourse['course'].startTime.contains('?')){
        datetime = DateFormat('Hm').parse(time);
      }

      return datetime;
    }

    /// Build list of child
    List<Widget> buildChildren() {
      List<Widget> builder = [];

      // Check if widget contains courses to display
      if (widget.courseWidgets.isNotEmpty) {
        // Add list of coursesWidgets
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

        // Check if a course is being reviewed
        if (reviewedCourse != null) {
          // Add a timePicker widget to allow the review
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
        // Display placeholder text when widget list is empty.
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

    /// Add children to the widget tree
    return Stack(
        children: buildChildren(),
    );

  }
}
