import 'package:pause_v1/user/schedule/Day.dart';

class Schedule {
  List<Day> _days;

  Schedule(schedule){
    _days = [];

    for (dynamic day in schedule['days']) {
      _days.add(Day(day));
    }
  }

  Map toJson() {
    List<Map> days = _days != null ? this._days.map((i) => i.toJson()).toList() : null;

    return {
      'days': days,
    };
  }

  List get days {
    return _days;
  }

}