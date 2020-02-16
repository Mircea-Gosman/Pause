import 'package:flutter/material.dart';

import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  File imageFile = null;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;

      // Firebase Interpretation of Image
      //reachFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    reachFirebase();

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:
        Center(
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
            new Container(
              child: Image.file(imageFile),
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      /*
      double minX =  0;
      double maxX =  0;
      double minY =  0;
      double maxY =  0;

      if(block.boundingBox.topLeft.dx < block.boundingBox.bottomLeft.dx) {
        minX = block.boundingBox.topLeft.dx.toDouble();
      } else {
        minX = block.boundingBox.bottomLeft.dx.toDouble();
      }

      if(block.boundingBox.topRight.dx > block.boundingBox.bottomRight.dx) {
        maxX = block.boundingBox.topRight.dx.toDouble();
      } else {
        maxX = block.boundingBox.bottomRight.dx.toDouble();
      }

      if(block.boundingBox.topRight.dy > block.boundingBox.topLeft.dy) {
        maxY = block.boundingBox.topRight.dy.toDouble();
      } else {
        maxY = block.boundingBox.topLeft.dy.toDouble();
      }

      if(block.boundingBox.bottomRight.dy < block.boundingBox.bottomLeft.dy) {
        minY = block.boundingBox.bottomRight.dy.toDouble();
      } else {
        minY = block.boundingBox.bottomLeft.dy.toDouble();
      }

      blocks.add([minX, minY, maxX, maxY]);
      */
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
                /*
                for(TextElement e in line.elements){
                    double minX =  0;
                    double maxX =  0;
                    double minY =  0;
                    double maxY =  0;

                    if(e.boundingBox.topLeft.dx < e.boundingBox.bottomLeft.dx) {
                      minX = e.boundingBox.topLeft.dx.toDouble();
                    } else {
                      minX = e.boundingBox.bottomLeft.dx.toDouble();
                    }

                    if(e.boundingBox.topRight.dx > e.boundingBox.bottomRight.dx) {
                      maxX = e.boundingBox.topRight.dx.toDouble();
                    } else {
                      maxX = e.boundingBox.bottomRight.dx.toDouble();
                    }

                    if(e.boundingBox.topRight.dy > e.boundingBox.topLeft.dy) {
                      maxY = e.boundingBox.topRight.dy.toDouble();
                    } else {
                      maxY = e.boundingBox.topLeft.dy.toDouble();
                    }

                    if(e.boundingBox.bottomRight.dy < e.boundingBox.bottomLeft.dy) {
                      minY = e.boundingBox.bottomRight.dy.toDouble();
                    } else {
                      minY = e.boundingBox.bottomLeft.dy.toDouble();
                    }

                    blocks.add([minX, minY, maxX, maxY]);
                }*/
      }
      print(blocks);
    }
    reachServer(text,blocks.toString());
  }

  Future<File> pickImage() async {
    return  ImagePicker.pickImage(source: ImageSource.gallery);
  }

  Future<void> reachServer(String imageText, String linesBoundingBoxes) async {
    var url = 'http://192.168.1.17:5000/';
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
