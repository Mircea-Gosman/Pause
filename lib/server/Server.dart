/**-----------------------------------------------------------
 * Connection to the server
 *
 * 2020 Mircea Gosman, Terrebonne, Canada
 * email mirceagosman@gmail.com
 * --------------------------------------------------------- */
import 'dart:async';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import '../user/User.dart';
import '../Services/ImagePickerService.dart';


class Server {
  final String url = 'http://192.168.1.3:5000/';    // Server link
  final User user;                                  // Current user

  StreamController<String> finishedOperationStream; // UI callbacks reference
  Timer FriendListTimer;                            // Friend list polling timer

  /// Initiliazer
  Server(this.user);

  /// Authentication
  Future<bool> auth() async{
    final postResponse = await http.post(url + 'auth', body: {'key' : user.key, 'friendList' : JSON.jsonEncode(user.friendList)});

    // Return the operation's success
    return handleResponse(postResponse.statusCode, finishAuth, postResponse);
  }

  /// Complete authentication
  void finishAuth(userStatus){
    // Update user information
    user.logIn(userStatus);

    // Listen for server side friend list updates
    Timer.periodic(Duration(seconds: 10), (timer) {
      requestFriendListUpdate();
      FriendListTimer = timer;
    });

    // Log user login
    print('User successfully Logged in: ' + user.isLoggedIn.toString());
  }

  /// Sync friend list to server
  Future<bool> requestFriendListUpdate() async {
    final postResponse = await http.post(url + 'downloadFriends', body: {'key' : user.key, 'friendListLength' : JSON.jsonEncode(user.friendList.length)});

    // Return the operation's success
    return handleResponse(postResponse.statusCode, finishRequestFriendListUpdate, postResponse);
  }

  /// Update friend list user based on server response
  void finishRequestFriendListUpdate(friendListUpdate){
    user.setFriendList(friendListUpdate['friendList'], 'server');
  }

  /// Initiate schedule Analysis
  Future<bool> analyseSchedule() async {
    // Ask user to select an image
    File imageFile = await ImagePickerService.pickImage();

    // Make Multipart request to send file and text
    final mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split('/');

    // Compose request
    http.MultipartRequest requestFile = http.MultipartRequest('POST', Uri.parse(url + 'importSchedule'));
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('Schedule', imageFile.path, contentType : MediaType(mimeTypeData[0], mimeTypeData[1]));

    requestFile.fields['key'] = user.key;
    requestFile.fields['ext'] = mimeTypeData[1];
    requestFile.files.add(multipartFile);

    // Send request and await response
    final streamedResponse = await requestFile.send();
    final fileResponse = await http.Response.fromStream(streamedResponse);

    // Return the operation's success
    return handleResponse(fileResponse.statusCode, finishAnalyseSchedule, fileResponse);
  }

  /// Add analysed schedule to user
  void finishAnalyseSchedule(schedule){
    // Set user schedule
    user.setSchedule(schedule);

    // Add finishedEvent to Stream
    finishedOperationStream.add('AnalyseSchedule');

    // Log schedule import
    print('Schedule successfully imported: ' + (user.schedule != null).toString());
  }

  /// Update database schedule
  Future<bool> updateSchedule() async {
    // Encode user object
    String encodedUser = JSON.jsonEncode(user);

    // Send to server for update.
    final postResponse = await http.post(url + 'updateSchedule', body: {'user' : encodedUser});

    // Return the operation's success
    return handleResponse(postResponse.statusCode, finishUpdateSchedule, postResponse);
  }

  /// Log database schedule update status
  void finishUpdateSchedule(databaseStatus){
    print('Schedule successfully updated: ' + databaseStatus['hasUpdated'].toString());
  }

  /// Request schedule information from Database
  Future<bool>  querySchedule() async {
    final postResponse = await http.post(url + 'querySchedule', body: {'key' : user.key});

    // Return the operation's success
    return handleResponse(postResponse.statusCode, finishAnalyseSchedule, postResponse); // Change finishAnalyseSchedule for something customized if ever needed, it suits for now
  }

  /// Request-Response method mapping for error monitoring
  bool handleResponse(int responseStatusCode , Function onSuccess, http.Response postResponse){
    // Collect response
    final responseContent = JSON.jsonDecode(postResponse.body);

    // Operation's success flag
    bool success = false;

    // Function mapping & error monitoring
    switch(responseStatusCode){
      case 200:
        onSuccess(responseContent);
        success = true;
        break;
      case 400: // TODO: Create corresponding exception
      case 401: // TODO: Create corresponding exception
      case 403: // TODO: Create corresponding exception
      case 500: // TODO: Create corresponding exception
      default:  // TODO: Create corresponding exception

    }

    // Return the operation's success
    return success;
  }

}