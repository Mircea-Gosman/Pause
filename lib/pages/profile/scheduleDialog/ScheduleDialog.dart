import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/UploadDialog.dart';

import 'package:pause_v1/pages/profile/scheduleDialog/CorrectionDialog.dart';


class ScheduleDialog extends StatefulWidget {
  final StreamController<bool> scheduleStreamController;
  final StreamController<bool> dialogStreamController = StreamController<bool>.broadcast();

  ScheduleDialog({Key key, this.scheduleStreamController}) : super(key: key);


  @override
  _ScheduleDialogState createState() => _ScheduleDialogState();
}


class _ScheduleDialogState extends State<ScheduleDialog> {
  var dialogOpen = false;
  var showUploadScreen = true;

  @override
  void initState(){
    super.initState();
    widget.scheduleStreamController.stream.listen((status){
      setState(() {
        dialogOpen = status;
      });
    });
    widget.dialogStreamController.stream.listen((status){
      setState(() {
        showUploadScreen = status;
      });
    });
  }
  List<Widget> buildChildren() {
    List<Widget>  builder = [];

    if(dialogOpen) {
      // TODO: Add real back button
      builder.add(
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/Home');
            },
            child: Icon(Icons.arrow_back),
            tooltip: 'Return to Home Page',
            //child: Icon(Icons.add),
            heroTag: "btn3",
          )
      );

      if(showUploadScreen){
        builder.add(
            UploadDialog(scheduleStreamController: widget.scheduleStreamController, dialogStreamController: widget.dialogStreamController)
        );
      } else {
        builder.add(
            CorrectionDialog(scheduleStreamController: widget.scheduleStreamController, dialogStreamController: widget.dialogStreamController)
        );
      }
    }

    return builder;
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: buildChildren()
    );
  }
}
