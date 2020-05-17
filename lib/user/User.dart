/**-----------------------------------------------------------
 * Current user
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:pause_v1/user/schedule/Schedule.dart';

class User {
  String key;                   // Facebook key
  String profilePictureURL;     // Profile picture URL from Facebook
  bool isNew;                   // Registry status in database
  bool isLoggedIn = false;      // Client login status
  List<String> friendList;      // List of friends' keys from Facebook
  Schedule schedule;            // Analyzed schedule

  /// Initializer
  User(){
    this.friendList = [];
  }

  /// Update login status
  void logIn(userStatus) {
    this.isLoggedIn = true;

    this.isNew = userStatus['isNew'];
  }

  /// Create JSON version to send to server
  Map toJson() {
    Map preparedSchedule = schedule != null ? this.schedule.toJson() : null;

    // Map required parameters to strings
    return {
      'key': key,
      'schedule' : preparedSchedule,
    };
  }

  /// Schedule setter
  void setSchedule (schedule) {
    this.schedule = Schedule(schedule);
  }

  /// Friend list setter
  void setFriendList (List friendList, String provider) {
    // Provider is Facebook by default
    String identifier = 'id';

    // Account for server terminology change
    if (provider == 'server') {
      identifier = 'key';
    }

    // Reset friend list
    this.friendList = [];

    // Fill friend list
    for (dynamic friend in friendList){
      this.friendList.add(friend[identifier].toString());
    }

  }

}