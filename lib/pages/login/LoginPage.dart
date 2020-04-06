import 'package:flutter/material.dart';
import 'package:pause_v1/server/Server.dart';
import 'package:provider/provider.dart';
import '../../APIs/FbAPI.dart';

// Login page TODO: Handle return to this page while logged in (i.e. through Android back button press)

class LoginPage extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login Page',
            ),
            RaisedButton(
              color: Color(0xff3b5998),
              shape:RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
              ),
              textColor: Colors.white,
              onPressed: () {
                FbAPI.loginToFB(Provider.of<Server>(context, listen: false));
                Navigator.pushNamed(context, '/Home');
              },
              child: Text('Login with Facebook', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );

  }
}