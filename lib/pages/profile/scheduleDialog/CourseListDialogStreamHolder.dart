import 'package:flutter/material.dart';
import 'dart:async';

import 'CourseDialog.dart';

class CourseListDialogStreamHolder extends InheritedWidget {
  final StreamController<CourseDialog> outterCourseStreamController = StreamController<CourseDialog>.broadcast();
  final StreamController<Map> reviewTimeStreamController = StreamController<Map>.broadcast();
  final StreamController<Map> reviewRequestTimeStreamController = StreamController<Map>.broadcast();

  CourseListDialogStreamHolder({
    Key key,
    @required Widget child,
  }) :  assert(child != null),
        super(key: key, child: child);

  static CourseListDialogStreamHolder of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CourseListDialogStreamHolder>();
  }

  @override
  bool updateShouldNotify(CourseListDialogStreamHolder old) => true;


  // TODO: dispose of streams

}