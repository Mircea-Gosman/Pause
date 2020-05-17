/**-----------------------------------------------------------
 * The application's ProfilePage
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/ScheduleDialog.dart';
import 'ProfileOptions.dart';
import 'ProfileBar.dart';


class ProfilePage extends StatelessWidget {

  // Build the UI
  @override
  Widget build (BuildContext context) {
    // Instantiate UI components
    ProfileOptions profileOptions = ProfileOptions();                                                         // Lower buttons
    ProfileBar profileBar = ProfileBar.fromOptions(profileOptions.scheduleFlow.stream);                       // Upper screen components
    ScheduleDialog scheduleDialog = ScheduleDialog(scheduleStreamController: profileOptions.scheduleFlow);    // Schedule upload dialog

    /// Add UI components to a list
    List<Widget> buildChildren() {
      var builder = [
        profileBar,
        profileOptions,
        scheduleDialog,

        //TODO: Real Back Button
        /*FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/Home');
            },
            child: Icon(Icons.arrow_back),
            tooltip: 'Return to Home Page',
            //child: Icon(Icons.add),
            heroTag: "btn3",
          ),*/
      ];
      return builder;
    }

    // Add the component list to the widget tree
    return new Scaffold(
      body: Stack(
        children: buildChildren()
      ),
    );
  }
}