/**-----------------------------------------------------------
 * Schedule Day
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:pause_v1/user/schedule/Course.dart';

class Day {
  String _title;          // Day title i.e. 'Monday'
  List<Course> _courses;  // Courses the user has that day

  /// Initializer
  Day(serverDay) {
    _title = serverDay['title'];
    _courses = [];

    // Populate courses
    for (dynamic course in serverDay['courses']) {
      _courses.add(
          Course(
            course['startTime'],
            course['endTime'],
            course['text'],
          )
      );

    }
  }

  /// Convert to JSON
  Map toJson() {
    List<Map> courses = _courses != null ? _courses.map((i) => i.toJson()).toList() : null;

    return {
      'title': _title, //TODO: Enable this option on server
      'courses': courses,
    };
  }

  /// Courses setter
  set courses(List<Course> course) {
    this.courses = courses;
  }

  /// Courses getter
  List get courses {
    return _courses;
  }

  /// Title getter
  String get title {
    return _title;
  }
}