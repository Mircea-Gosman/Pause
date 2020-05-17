/**-----------------------------------------------------------
 * Dialog inciting the user to upload his schedule
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:provider/provider.dart';

/// UploadDialog parent widget
class UploadDialog extends StatefulWidget {
  final StreamController<bool> scheduleStreamController;  // Callback ref for closing the schedule dialog
  final StreamController<bool> dialogStreamController;    // Callback ref for opening the correction dialog

  /// Initializer
  UploadDialog({Key key,  this.scheduleStreamController, this.dialogStreamController}) : super(key: key);

  /// Create state
  @override
  _UploadDialogState createState() => _UploadDialogState();
}

/// UploadDialog state
class _UploadDialogState extends State<UploadDialog> {

  /// Initialize state
  @override
  void initState(){
    super.initState();

    // Listener init: Close dialog when the server finishes analyzing the schedule
    Provider.of<Server>(context, listen: false).finishedOperationStream = StreamController<String>.broadcast();
    Provider.of<Server>(context, listen: false).finishedOperationStream.stream.listen((operation){
      setState(() {
        if(operation == 'AnalyseSchedule'){
          widget.dialogStreamController.add(false);
          Provider.of<Server>(context, listen: false).finishedOperationStream.close();
        }
      });
    });
  }

  /// Build the UI
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[
          // Upload text
          Positioned(
            top: ScreenSize.unitHeight * 30,
            left: ScreenSize.unitWidth * 7,

            child: Text(
              'Upload your schedule',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenSize.unitHeight * 5),
            ),
          ),
          // Upload button
          Positioned(
            top: ScreenSize.unitHeight * 45,
            left: ScreenSize.unitWidth * 30,

            child: CircleAvatar(
              radius: ScreenSize.unitWidth * 20,
              backgroundColor: Colors.black,
              child: SizedBox.expand(
                child: IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                    size: ScreenSize.unitWidth * 19,
                  ),
                  onPressed: () {
                    // Analyse schedule using the server
                    Provider.of<Server>(context, listen: false).analyseSchedule();
                  },
                ),
              ),
            ),
          ),
          // Back button
          Positioned(
            top: ScreenSize.unitHeight * 65,
            left: ScreenSize.unitWidth * 39,

            child: CircleAvatar(
              radius: ScreenSize.unitWidth * 11,
              backgroundColor: Colors.white,
              child:CircleAvatar (
                radius: ScreenSize.unitWidth * 10,
                backgroundColor: Colors.black,
                child: SizedBox.expand(
                  child: IconButton(
                    padding: EdgeInsets.all(0.0),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: ScreenSize.unitWidth * 14,
                    ),
                    onPressed: () {
                      // Close the schedule dialog
                      widget.scheduleStreamController.add(false);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
    );
  }
}
