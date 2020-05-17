/**-----------------------------------------------------------
 * Schedule dialogs holder
 * (swaps between UploadDialog and CorrectionDialog)
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/UploadDialog.dart';

import 'package:pause_v1/pages/profile/scheduleDialog/CorrectionDialog.dart';

/// ScheduleDialog parent widget
class ScheduleDialog extends StatefulWidget {
  final StreamController<bool> scheduleStreamController;                                    // Close the schedule dialog
  final StreamController<bool> dialogStreamController = StreamController<bool>.broadcast(); // Callback to swap btw dialogs

  /// Initializer
  ScheduleDialog({Key key, this.scheduleStreamController}) : super(key: key);

  /// Create state
  @override
  _ScheduleDialogState createState() => _ScheduleDialogState();
}

/// Schedule dialog state
class _ScheduleDialogState extends State<ScheduleDialog> {
  var dialogOpen = false;       // To show schedule dialog or not
  var showUploadScreen = true;  // Which dialog to show (false => show correction dialog)

  /// Initialize state
  @override
  void initState(){
    super.initState();

    // Listen to the
    widget.scheduleStreamController.stream.listen((status){
      // bool status: Open or close the schedule dialog
      setState(() {
        dialogOpen = status;
      });
    });
    widget.dialogStreamController.stream.listen((status){
      // bool status: swap btw dialogs
      setState(() {
        showUploadScreen = status;
      });
    });
  }

  /// Build list of children
  List<Widget> buildChildren() {
    List<Widget>  builder = [];

    // Verify if schedule dialog should be open
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

      // Verify which dialog to open
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

  /// Add built list of children to widget tree
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: buildChildren()
    );
  }
}
