import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import 'package:pause_v1/server/Server.dart';

class FbAPI {
  static Future<void> loginToFB(Server server) async{
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['user_friends']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        // Get user data from Facebook
        _getGeneralUser(result.accessToken.token, server);
        break;
      case FacebookLoginStatus.cancelledByUser:
      //TODO: Show appropriate error message
        break;
      case FacebookLoginStatus.error:
      //TODO: Show appropriate error message
        break;
    }
  }

  static void _getGeneralUser(String token, Server server) async{
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=id,picture,friends&access_token=${token}');
    final profile = JSON.jsonDecode(graphResponse.body);
    final profilePictureURL = profile['picture']['data']['url']; // Format of picture obj.: {data: {height: 50, is_silhouette: false, url: https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=2244735515835110&height=50&width=50&ext=1585085593&hash=AeT70MYhWvAdn6ua, width: 50}}
    final friendList = profile['friends']['data'];               // Format of friends obj.: {data: [], summary: {total_count: 216}} ;; it only includes friends that use the app & who give permission

    server.user.key = profile['id'];
    server.user.profilePictureURL = profilePictureURL; //TODO: Store the picture locally
    // TODO: Friend list should be an event and should be in separate method

    await server.auth();
  }

}