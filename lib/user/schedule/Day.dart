import 'package:pause_v1/user/schedule/Course.dart';

class Day {
  String _title;
  List<Course> _courses;

  Day(serverDay) {
    _title = serverDay['title'];
    _courses = [];

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

  Map toJson() {
    List<Map> courses = _courses != null ? _courses.map((i) => i.toJson()).toList() : null;

    return {
      'title': _title, //TODO: Enable this option on server
      'courses': courses,
    };
  }

  List get courses {
    return _courses;
  }

  String get title {
    return _title;
  }

  set courses(List<Course> course) {
    this.courses = courses;
  }
}