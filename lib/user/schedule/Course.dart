/**-----------------------------------------------------------
 * Schedule course
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */

class Course {
  String _startTime; // Start timestamp content
  String _endTime;   // End timestamp content
  String _text;      // Course content

  /// Initializer
  Course(String startTime, String endTime, this._text){
    // Format times to match DateTime() format
    this._startTime = parseTime(startTime);
    this._endTime = parseTime(endTime);
  }

  /// Convert to JSON
  Map toJson() => {
    'startTime': _startTime,
    'endTime': _endTime,
    'text': _text,
  };

  /// Text setter
  set text(String newText) {
     _text = newText;
  }

  /// StartTime setter
  set startTime(String startTime) {
    _startTime = startTime;
  }

  /// EndTime setter
  set endTime(String endTime) {
    _endTime = endTime;
  }

  /// StartTime getter
  get startTime {
    return _startTime;
  }

  /// EndTime getter
  get endTime {
    return _endTime;
  }

  /// Parse time for DateTime format
  String parseTime(String time){
    if (!time.contains('?')){
      time  = time.substring(0, 2) + ':' + time.substring(2, 4);
    }

    return time;
  }
}