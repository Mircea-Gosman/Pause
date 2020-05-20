/**-----------------------------------------------------------
 * UploadDialog TimeStamps
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/CourseListDialogStreamHolder.dart';
import 'package:pause_v1/services/screenSize.dart';

/// TimeStamp parent widget
class TimeStamp extends StatefulWidget {
  double indent; // Indentation appliquée lorsque le texte est trop court (i.e. '?')
  Map source;    // Source des informations du widget


  TimeStamp({Key key, this.indent, @required this.source}) : super(key: key);

  @override
  _TimeStampState createState() => _TimeStampState();

}

/// TimeStamp state
class _TimeStampState extends State<TimeStamp> {
  // Build UI
  @override
  Widget build(BuildContext context) {
    // Listen to reviewTimeStream for content updates
    CourseListDialogStreamHolder.of(context).reviewTimeStreamController.stream.listen((updatedSource){
      // Check if the update occured on this TimeStamp
      if(updatedSource['course'] == widget.source['course'] && updatedSource['isStart'] == widget.source['isStart']){
        setState(() {
          widget.source['time'] = updatedSource['time'];
        });
      }
    });

    // Check for null content
    bool nullText = widget.source['time'] == null;

    // Indent question marks for positioning
    if (nullText) {
      if(widget.indent != null)
        widget.indent += ScreenSize.unitWidth * 10;
      else
        widget.indent = ScreenSize.unitWidth * 9;
    }

    // Build UI
    return Positioned(
          left: widget.indent == null ? 0 : widget.indent,

          child: Text(
            !nullText ? widget.source['time'] : '?',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: ScreenSize.unitHeight * 5,
                color: widget.source['time'].contains('?') || nullText ? Colors.red : Colors.black
            ),
          ),
        );
  }
}





