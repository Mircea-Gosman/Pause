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

  Server(this.user);

  // Authentication
  Future<String> auth() async{
    final postResponse = await http.post(url + 'auth', body: {'key' : user.key});

    switch(postResponse.statusCode){
      case 200:
        directEntryFlow(postResponse);
        break;
      case 400: // TODO: Create corresponding exception
      case 401: // TODO: Create corresponding exception
      case 403: // TODO: Create corresponding exception
      case 500: // TODO: Create corresponding exception
      default:  // TODO: Create corresponding exception
        return 'error';
    }


  }

  // On app entry flow
  void directEntryFlow(http.Response postResponse){
    final userStatus = JSON.jsonDecode(postResponse.body);

    // Update user information
    user.logIn(userStatus);

    // Register flow
    if (userStatus['isNew']) {
      // TODO: Activate new-user tips and go to Profile page
      print('NewUser!');
    }

  }


  // Schedule Analysis
  Future<void> analyseSchedule() async {
    File imageFile = await ImagePickerService.pickImage();

    // Make standard get request
    //var response = await http.get(url);

    // Make Multipart request to send file and text
    final mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split('/');

    http.MultipartRequest requestFile = http.MultipartRequest('POST', Uri.parse(url + 'schedule'));
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('Schedule', imageFile.path, contentType : MediaType(mimeTypeData[0], mimeTypeData[1]));

    requestFile.fields['key'] = user.key;
    requestFile.fields['ext'] = mimeTypeData[1];
    requestFile.files.add(multipartFile);

    final streamedResponse = await requestFile.send();
    final fileResponse = await http.Response.fromStream(streamedResponse);

    print(fileResponse.body);
  }

}