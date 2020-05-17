/**-----------------------------------------------------------
 * Facebook API connection
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import 'package:pause_v1/server/Server.dart';

class FbAPI {

  /// Authenticate to Facebook
  static Future<void> loginToFB(Server server) async{
    final facebookLogin = FacebookLogin();                      // FB Ref
    final result = await facebookLogin.logIn(['user_friends']); // FB Auth

    // Monitor Facebook authentication response
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        // Store user data from Facebook into User
        _getGeneralUser(result.accessToken.token, server);
        break;
      case FacebookLoginStatus.cancelledByUser:
      //TODO: Show appropriate error message
        break;
      case FacebookLoginStatus.error:
      //TODO: Show appropriate error message
        print('authenticating');
        break;
      default:
        print('FacebookLogInError');
    }
  }

  /// Authenticate with server
  static void _getGeneralUser(String token, Server server) async{
    // Get Facebook user data
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=id,picture,friends&access_token=${token}');

    // Parse said data
    final profile = JSON.jsonDecode(graphResponse.body);

    // Update user with the parsed data
    server.user.key = profile['id'];
    server.user.profilePictureURL = profile['picture']['data']['url']; //TODO: Store the picture locally
    server.user.setFriendList(profile['friends']['data'], 'fb');
    // TODO: Configure server-side webhooks for facebook native post-login friend List updates.

    // Proceed to authenticate with the server
    await server.auth();
  }

}