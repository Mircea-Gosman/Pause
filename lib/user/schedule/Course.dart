class Course {
  String _startTime; // TODO: Format this on server to make it an integer
  String _endTime;   // TODO: Format this on server to make it an integer
  String _text;

  Course(this._startTime, this._endTime, this._text);

  Map toJson() => {
    'startTime': _startTime,
    'endTime': _endTime,
    'text': _text,
  };

  set text(String newText) {
     _text = newText;
  }
}