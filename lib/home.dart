import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:trushot/camera.dart';
import 'package:trushot/database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database database;
  List<String> photoKeys;

  @override
  void initState() {
    super.initState();
    database = Database();
    photoKeys = database.getPhotoKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPhotosLists(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<CameraDescription> cameras = await availableCameras();
          
          await Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return TakePictureScreen(
                camera: cameras.first,
                database: database,
              );
            }
          ));
          setState(() {
            photoKeys = database.getPhotoKeys();
          });
        },
        tooltip: 'Take picture',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getPhotosLists() {
    if(photoKeys.length == 0) {
      return Center(
        child: Text(
          'Nothing to see here'
        )
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        if(index < photoKeys.length) {
          return ListTile(
            title: Text(
              photoKeys[index]
            ),
          );
        }
        return null;
      },
    );
  }
}