/**-----------------------------------------------------------
 * Inherited widget allowing to pass
 * streams down to all children
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';
import 'dart:async';

import 'CourseDialog.dart';

class CourseListDialogStreamHolder extends InheritedWidget {
  final StreamController<CourseDialog> outterCourseStreamController = StreamController<CourseDialog>.broadcast();  // Callback ref for removing timeStamps from the user
  final StreamController<Map> reviewTimeStreamController = StreamController<Map>.broadcast();                      // Callback ref for changing timeStamp references
  final StreamController<Map> reviewRequestTimeStreamController = StreamController<Map>.broadcast();               // Callback ref for updating the user's timeStamps content

  /// Initializer
  CourseListDialogStreamHolder({
    Key key,
    @required Widget child,
  }) :  assert(child != null),
        super(key: key, child: child);

  /// Allow children to depend on this widget and access all its contents
  static CourseListDialogStreamHolder of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CourseListDialogStreamHolder>();
  }

  /// Notify children that depend on this widget when this widget is rebuilt
  @override
  bool updateShouldNotify(CourseListDialogStreamHolder old) => true;


  // TODO: dispose of streams

}