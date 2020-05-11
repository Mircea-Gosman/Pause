import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/services/screenSize.dart';


class TimeStamp extends StatefulWidget {
  double indent;
  Map source;


  TimeStamp({Key key, this.indent, @required this.source}) : super(key: key);

  @override
  _TimeStampState createState() => _TimeStampState();

}

class _TimeStampState extends State<TimeStamp> {
  @override
  void initState(){
    super.initState();

  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {

    CourseListDialogStreamHolder.of(context).reviewTimeStreamController.stream.listen((updatedSource){
     // print('timestamp:');
      //print(updatedSource['time']);

      if(updatedSource['course'] == widget.source['course'] && updatedSource['isStart'] == widget.source['isStart']){
        setState(() {
          widget.source['time'] = updatedSource['time'];
        });
      }
    });

    bool nullText = widget.source['time'] == null;

    // Indent questionmarks
    if (nullText) {
      if(widget.indent != null)
        widget.indent += ScreenSize.unitWidth * 10;
      else
        widget.indent = ScreenSize.unitWidth * 9;

    }

    return Positioned(
          left: widget.indent == null ? 0 : widget.indent,

          child: Text(
            !nullText ? widget.source['time'] : '?',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: ScreenSize.unitHeight * 5, color: widget.source['time'].contains('?') || nullText ? Colors.red : Colors.black),
          ),
        );
  }
}





