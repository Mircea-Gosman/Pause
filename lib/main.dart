/**-----------------------------------------------------------
* Application entry point
*
* 2020 Mircea Gosman, Terrebonne, Canada
* email mirceagosman@gmail.com
* --------------------------------------------------------- */

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'user/User.dart';
import 'server/Server.dart';
import 'pages/Routes.dart';

/// Entry point of the application
void main() => runApp(Pause(server: Server(User())));

/// Root widget of the application
class Pause extends StatelessWidget {
  // Flask server communication tool
  final Server server;

  /// Initializer
  Pause({Key key, @required this.server}) : super(key: key);


  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    // Block Screen orientation in whole app
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Direct to Login on launch
    String initialRoute = '/Login';

    // Skip Login if it already happened
    if (server.user.isLoggedIn) {
      initialRoute = '/Home';
    }

    // Make the Server available troughout the app
    return Provider<Server>.value(
        value: server,

        //Create Material App
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.grey,
          ),
          initialRoute: initialRoute,
          // Routes' map
          routes: routes,
        ),
    );
  }
}

/*
---------------------------------------------------------------------------------------------------------
References:
---------------------------------------------------------------------------------------------------------
Provider [ https://pub.dev/packages/provider ] idea:
https://medium.com/coding-with-flutter/flutter-global-access-vs-scoped-access-with-provider-8d6b94393bdf

Project file structure idea:
https://medium.com/flutter-community/flutter-code-organization-revised-b09ad5cef7f6
---------------------------------------------------------------------------------------------------------
 */
