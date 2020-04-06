import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'user/User.dart';
import 'server/Server.dart';
import 'pages/Routes.dart';

void main() => runApp(Pause(server: Server(User())));

class Pause extends StatelessWidget {
  final Server server;

  Pause({Key key, @required this.server}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Block Screen orientation in whole app
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    String initialRoute = '/Login';
    if (server.user.isLoggedIn) {
      initialRoute = '/Home';
    }

    return Provider<Server>.value(
        value: server,
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          //home: Login(),
          initialRoute: initialRoute,
          routes: routes,
        ),
    );
  }
}

// Provider [ https://pub.dev/packages/provider ] idea:
// https://medium.com/coding-with-flutter/flutter-global-access-vs-scoped-access-with-provider-8d6b94393bdf

// Project file structure idea:
// https://medium.com/flutter-community/flutter-code-organization-revised-b09ad5cef7f6