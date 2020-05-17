/**-----------------------------------------------------------
 * The application's LoginPage
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter/material.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:pause_v1/services/screenSize.dart';
import 'package:provider/provider.dart';
import '../../APIs/FbAPI.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    // Initialize ScreenSize if necessary
    if(!ScreenSize.initialized) {
      // ScreenSize
      ScreenSize().init(context);
    }

    // Build UI
    return new Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Page identifier
            Text(
              'Login Page',
            ),
            // Login button
            RaisedButton(
              color: Color(0xff3b5998),
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
              ),
              textColor: Colors.white,
              onPressed: () {
                Server server = Provider.of<Server>(context, listen: false);
                FbAPI.loginToFB(server);

                // Register flow
                if (server.user.isNew) {
                  // TODO: Create troughout the app new-user tips
                  Navigator.pushNamed(context, '/Profile');
                } else {
                  Navigator.pushNamed(context, '/Home');
                }

              },
              child: Text('Login with Facebook', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );

  }
}