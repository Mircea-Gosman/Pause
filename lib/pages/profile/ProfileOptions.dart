import 'package:flutter/material.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:provider/provider.dart';

import '../../Services/LocationService.dart';


// Profile page buttons set
class ProfileOptions extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Add Schedule Button
        Positioned(
          top: (MediaQuery.of(context).size.height) * 0.8,
          left: (MediaQuery.of(context).size.width) * 0.3,

          child:  FlatButton(
            color: Colors.black,
            textColor: Colors.white,
            shape: CircleBorder(),
            onPressed: () {

              Provider.of<Server>(context, listen: false).analyseSchedule();
              // TODO: Show additional dialogs, ie. schedule adjustments, etc.
            },
            child: new Icon(Icons.add, size: 115),
          ),
        ),
        // Geolocalisation button
        Positioned(
          top: (MediaQuery.of(context).size.height) * 0.715,
          left: (MediaQuery.of(context).size.width) * 0.07,
          width: 85,
          height: 85,
          child:  FlatButton(
            color: Colors.black,
            textColor: Colors.white,
            shape: CircleBorder(),
            onPressed: () {
              LocationService.setLocationAvailable();
              // TODO
            },
            child: new Icon(Icons.location_on, size: 42.5),
          ),
        ),
        // Do not disturb button
        Positioned(
          top: (MediaQuery.of(context).size.height) * 0.7,
          left: (MediaQuery.of(context).size.width) * 0.63,

          child:  FlatButton(
            //color: Colors.white,
            textColor: Colors.black,
            shape: CircleBorder(),
            onPressed: () {
              // TODO
            },
            child: new Icon(Icons.do_not_disturb_on, size: 100),
          ),
        ),
      ],

    );
  }
}
