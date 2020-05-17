/**-----------------------------------------------------------
 * User Schedule
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:pause_v1/user/schedule/Day.dart';

class Schedule {
  List<Day> _days;  // Schedule days

  /// Initializer
  Schedule(schedule){
    _days = [];

    // Populate days
    for (dynamic day in schedule['days']) {
      _days.add(Day(day));
    }
  }

  /// Convert to JSON
  Map toJson() {
    List<Map> days = _days != null ? this._days.map((i) => i.toJson()).toList() : null;

    return {
      'days': days,
    };
  }

  /// Days getter
  List get days {
    return _days;
  }

}