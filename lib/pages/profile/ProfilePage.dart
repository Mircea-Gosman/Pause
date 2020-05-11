import 'package:flutter/material.dart';
import 'package:pause_v1/pages/profile/scheduleDialog/ScheduleDialog.dart';
import 'ProfileOptions.dart';
import 'ProfileBar.dart';


class ProfilePage extends StatelessWidget {
  var addDialog = false;

  @override
  Widget build (BuildContext context) {
    ProfileOptions profileOptions = ProfileOptions();
    ProfileBar profileBar = ProfileBar.fromOptions(profileOptions.scheduleFlow.stream);
    ScheduleDialog scheduleDialog = ScheduleDialog(scheduleStreamController: profileOptions.scheduleFlow);

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

    return new Scaffold(
      body: Stack(
        children: buildChildren()
      ),
    );
  }
}