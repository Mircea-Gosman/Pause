import 'package:flutter/material.dart';

import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: Login(),
    );
  }
}

// Login page
class Login extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new Scaffold(
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Display picked image in UI
              //new Container(
              //  child: Image.file(imageFile),
              //),
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
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => new MyHomePage()),
                  );
                },
                child: Text('Login with Facebook', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
    );
  }
}

// Profile page
class Profile extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    return new
        Stack(
          children: <Widget>[
            ProfileBar(),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (context) => new MyHomePage(title: "Pause")),
                );
              },
              tooltip: 'Return to Home Page',
              //child: Icon(Icons.add),
              heroTag: "btn3",
            ),
            ProfileOptions(),

            //ProfileOptions(),
          ],
        );
  }
}

// Central app page
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    // TODO: Set properties to paint
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;

    var path = Path();

    // TODO: Draw your path
    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height / 2.5, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// App Bar
class ProfileBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: CurvePainter(),
        child:  Stack(
          children: <Widget>[
            // Profile
            Positioned(
              top: (MediaQuery.of(context).size.height) * 0.1,
              left: (MediaQuery.of(context).size.width) * 0.36,
              width: 100,
              height: 100,
              child:  FlatButton(
                color: Colors.white,
                shape: CircleBorder(),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => new Profile()),
                  );
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
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => new Login()),
                  );
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

// Profile page buttons set
class ProfileOptions extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
          children: <Widget>[
            // Profile
            Positioned(
              top: (MediaQuery.of(context).size.height) * 0.5,
              left: (MediaQuery.of(context).size.width) * 0.36,

              child:  FlatButton(
                color: Colors.black,
                textColor: Colors.white,
                shape: CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => new Profile()),
                  );
                },
                child: new Icon(Icons.add, size: 100),
              ),

            ),

          ],

        ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  File imageFile = null;


  void _uiLink() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
    // Firebase Interpretation of Image
    reachFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileBar(),
    );
  }

  Future<void> reachFirebase() async {
    imageFile =  await pickImage();
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(imageFile);
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    final VisionText visionText = await textRecognizer.processImage(visionImage);
    String text = visionText.text;
    var blocks = new List();

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
                double minX =  0;
                double maxX =  0;
                double minY =  0;
                double maxY =  0;

                if(line.boundingBox.topLeft.dx < line.boundingBox.bottomLeft.dx) {
                   minX = line.boundingBox.topLeft.dx.toDouble();
                } else {
                   minX = line.boundingBox.bottomLeft.dx.toDouble();
                }

                if(line.boundingBox.topRight.dx > line.boundingBox.bottomRight.dx) {
                  maxX = line.boundingBox.topRight.dx.toDouble();
                } else {
                  maxX = line.boundingBox.bottomRight.dx.toDouble();
                }

                if(line.boundingBox.topRight.dy > line.boundingBox.topLeft.dy) {
                  maxY = line.boundingBox.topRight.dy.toDouble();
                } else {
                  maxY = line.boundingBox.topLeft.dy.toDouble();
                }

                if(line.boundingBox.bottomRight.dy < line.boundingBox.bottomLeft.dy) {
                  minY = line.boundingBox.bottomRight.dy.toDouble();
                } else {
                  minY = line.boundingBox.bottomLeft.dy.toDouble();
                }

                blocks.add([minX, minY, maxX, maxY]);
      }
      print(blocks);
    }
    reachServer(text,blocks.toString());
  }

  Future<File> pickImage() async {
    return  ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> reachServer(String imageText, String linesBoundingBoxes) async {
    var url = 'http://10.0.2.2:5000/'; // 10.0.2.2 [school] or 192.168.1.17 [home]
    /* Make standard get request
    var response = await http.get(url);
    */
    /* Make standard post request with text body
    var postResponse = await http.post(url, body: {'key' : imageText});
     */

    // Make Multipart request to send file and text
    final mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split('/');

    http.MultipartRequest requestFile = http.MultipartRequest('POST', Uri.parse(url));
    http.MultipartFile multipartFile = await http.MultipartFile.fromPath('Schedule', imageFile.path, contentType : MediaType(mimeTypeData[0], mimeTypeData[1]));

    requestFile.fields['ext'] = mimeTypeData[1];
    requestFile.files.add(multipartFile);
    requestFile.fields['imageText'] = imageText;
    requestFile.fields['linesBoundingBoxes'] = linesBoundingBoxes;

    final streamedResponse = await requestFile.send();
    final fileResponse = await http.Response.fromStream(streamedResponse);

    print(fileResponse.body);
  }


}
