import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trushot/camera.dart';
import 'package:trushot/database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database database;
  Future<List<String>> photoKeysFuture;

  @override
  void initState() {
    super.initState();
    database = Database();
    photoKeysFuture = database.getPhotoKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: photoKeysFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return getPhotosLists(snapshot.data);
          }
          else if(snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text(
                'There was a problem. Please try again later.'
              ),
            );
          }
          else {
            return Center(
              child: const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              )
            );
          }
        }
      ),
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
            photoKeysFuture = database.getPhotoKeys();
          });
        },
        tooltip: 'Take picture',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget getPhotosLists(List<String> photoKeys) {
    photoKeys = photoKeys ?? ['key'];//TODO change to empty list

    if(photoKeys.length == 0) {
      return Center(
        child: Text(
          'Nothing to see here'
        )
      );
    }

    void copyToClipboard(String input, BuildContext context) {
      Clipboard.setData(ClipboardData(text: input));
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(text: input, style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ' copied to clipboard'),
              ],
            ),
          )
        )
      );
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        if(index < photoKeys.length) {
          final String code = photoKeys[index];

          return ListTile(
            onTap: () {
              copyToClipboard(code, context);
            },
            onLongPress: () {
              copyToClipboard(code, context);
            },
            title: Text(
              code
            ),
          );
        }
        return null;
      },
    );
  }
}