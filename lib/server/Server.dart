import 'dart:async';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;

import '../user/User.dart';
import '../Services/ImagePickerService.dart';


class Server {
  String url = 'http://192.168.1.4:5000/'; // 10.0.2.2 [school_emulator] or 10.150.139.93 [school_real_phone] or 192.168.1.4 [home]
  User user;
  Timer FriendListTimer; // use this to close the timer.

  Server(this.user);

  // Authentication
  Future<bool> auth() async{
    final postResponse = await http.post(url + 'auth', body: {'key' : user.key, 'friendList' : JSON.jsonEncode(user.friendList)});

    return handleResponse(postResponse.statusCode, finishAuth, postResponse);
  }

  // On app entry flow
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

  Future<bool> requestFriendListUpdate() async {
    final postResponse = await http.post(url + 'downloadFriends', body: {'key' : user.key, 'friendListLength' : JSON.jsonEncode(user.friendList.length)});

    return handleResponse(postResponse.statusCode, finishRequestFriendListUpdate, postResponse);
  }

  void finishRequestFriendListUpdate(friendListUpdate){
    user.setFriendList(friendListUpdate['friendList'], 'server');
  }

  // Schedule Analysis
  Future<bool> analyseSchedule() async {
    File imageFile = await ImagePickerService.pickImage();

    // Make standard get request
    //var response = await http.get(url);

    // Make Multipart request to send file and text
    final mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split('/');

    http.MultipartRequest requestFile = http.MultipartRequest('POST', Uri.parse(url + 'importSchedule'));
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('Schedule', imageFile.path, contentType : MediaType(mimeTypeData[0], mimeTypeData[1]));

    requestFile.fields['key'] = user.key;
    requestFile.fields['ext'] = mimeTypeData[1];
    requestFile.files.add(multipartFile);

    final streamedResponse = await requestFile.send();
    final fileResponse = await http.Response.fromStream(streamedResponse);

    return handleResponse(fileResponse.statusCode, finishAnalyseSchedule, fileResponse);
  }

  // Add schedule to user
  void finishAnalyseSchedule(schedule){
    user.setSchedule(schedule);

    // Log schedule import
    print('Schedule successfully imported: ' + (user.schedule != null).toString());
  }

  Future<bool> updateSchedule() async {
    // Encode user object
    String encodedUser = JSON.jsonEncode(user);

    // Send to server for update.
    final postResponse = await http.post(url + 'updateSchedule', body: {'user' : encodedUser});

    return handleResponse(postResponse.statusCode, finishUpdateSchedule, postResponse);
  }

  // Log schedule update
  void finishUpdateSchedule(databaseStatus){
    print('Schedule successfully updated: ' + databaseStatus['hasUpdated'].toString());
  }

  bool handleResponse(int responseStatusCode , Function onSuccess, http.Response postResponse){
    final responseContent = JSON.jsonDecode(postResponse.body);
    bool success = false;

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

    return success;
  }

}