import 'package:flutter/material.dart';

import '../../painters/ProfileBarPainter.dart';

// App Bar
class ProfileBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: ProfileBarPainter(),
        child:  Stack(
          children: <Widget>[
            // Profile
            Positioned(
              top: (MediaQuery.of(context).size.height) * 0.1,
              left: (MediaQuery.of(context).size.width) * 0.36,
              width: 100,
              height: 100,
              child: FlatButton(
                color: Colors.white,
                shape: CircleBorder(),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/Profile');
                },
              ),
            ),
            Positioned(
              top: (MediaQuery.of( context).size.height) * 0.2,
              left: (MediaQuery.of(context).size.width) * 0.64,
              width: 30,
              height: 30,
              child:  IconButton(
                color: Colors.white,
                //shape: CircleBorder(),
                //textColor: Colors.white,
                onPressed: () {
                  // TODO
                },
                icon: Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
