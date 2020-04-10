import 'package:pause_v1/user/schedule/Schedule.dart';

class User {
  String key;
  String profilePictureURL;
  bool isNew;
  bool isLoggedIn = false;
  List<String> friendList;
  Schedule schedule;

  User(){
    this.friendList = [];
  }

  void logIn(userStatus) {
    this.isLoggedIn = true;
    //this.isNew = userStatus['isNew'];
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

  void setFriendList (List friendList, String provider) {
    String identifier = 'id'; // Facebook by default

    if (provider == 'server') {  // Server terminology is different
      identifier = 'key';
    }

    // Reset friend list
    this.friendList = [];

    for (dynamic friend in friendList){
      this.friendList.add(friend[identifier].toString());
    }

  }

}