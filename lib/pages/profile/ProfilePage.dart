import 'package:flutter/material.dart';
import 'ProfileOptions.dart';
import 'ProfileBar.dart';


class ProfilePage extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      body: Stack(
        children: <Widget>[
          ProfileBar(),
          ProfileOptions(),
          //TODO: Real Back Button
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/Home');
            },
            child: Icon(Icons.arrow_back),
            tooltip: 'Return to Home Page',
            //child: Icon(Icons.add),
            heroTag: "btn3",
          ),
        ],
      ),
    );
  }
}