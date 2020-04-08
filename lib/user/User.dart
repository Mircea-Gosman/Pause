import 'package:pause_v1/user/schedule/Schedule.dart';

class User {
  String key;
  String profilePictureURL;
  bool isNew;
  bool isLoggedIn = false;
  Schedule schedule;

  User();

  void logIn(userStatus) {
    this.isLoggedIn = true;
    this.isNew = userStatus['isNew'];
  }

  Map toJson() {
    Map preparedSchedule = schedule != null ? this.schedule.toJson() : null;

    return {
      'key': key,
      'schedule' : preparedSchedule,
    };
  }

  void setSchedule (schedule) {
    this.schedule = Schedule(schedule);
  }

}