import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'package:trushot/database.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final Database database;

  const TakePictureScreen({
    Key key,
    @required this.camera,
    @required this.database
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final String path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            await _controller.takePicture(path);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: path,
                  database: widget.database,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Database database;

  const DisplayPictureScreen({Key key, @required this.imagePath, @required this.database}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      body: Image.file(File(imagePath)),
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            child: Icon(
              Icons.clear,
            ),
            onPressed: () {
              handleClear(context);
            },
            heroTag: null,
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(           
            child: Icon(
              Icons.check,
            ),
            onPressed: () {
              handleKeep(context);
            },
            heroTag: null,
          ),
        ]
      ),
    );
  }

  void handleClear(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> handleKeep(BuildContext context) async {
    const String url = 'PLACEHOLDER';//TODO: Put correct link

    final File file = File(imagePath);
    final Uint8List byteList = await file.readAsBytes();
    
    Response response;
    try {
      response = await post(url, body: byteList);
    } catch(e) {
      print(e);
      await handleError(context);
    }

    if(response.statusCode != 200) {
      await handleError(context);
    }
    else {
      await database.addPhotoKey(response.body);
    }
    
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> handleError(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Oops!"),
          content: Text("There was a problem handling your request."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}