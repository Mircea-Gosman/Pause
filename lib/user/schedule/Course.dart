class Course {
  String _startTime;
  String _endTime;
  String _text;

  Course(String startTime, String endTime, this._text){
    // Format times to match DateTime() format
    this._startTime = parseTime(startTime);
    this._endTime = parseTime(endTime);
    print('InitialCourse:');
    print(startTime);
    print(endTime);
  }

  Map toJson() => {
    'startTime': _startTime,
    'endTime': _endTime,
    'text': _text,
  };

  set text(String newText) {
     _text = newText;
  }

  set startTime(String startTime) {
    print('ChangedStartTime');
    print(startTime);
    _startTime = startTime;
  }

  set endTime(String endTime) {
    print('ChangedStartTime');
    print(endTime);
    _endTime = endTime;
  }

  get startTime {
    return _startTime;
  }

  get endTime {
    return _endTime;
  }

  String parseTime(String time){
    if (!time.contains('?')){
      time  = time.substring(0, 2) + ':' + time.substring(2, 4);
    }

    return time;
  }
}