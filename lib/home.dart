import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
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
          final ImagePicker picker = ImagePicker();
          final PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);

          if(pickedFile == null) {
            return;
          }

          final Uint8List imageData = await pickedFile.readAsBytes();
          await handleKeep(context, imageData);

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

  Future<void> handleKeep(BuildContext context, Uint8List image) async {
    const String url = 'PLACEHOLDER';//TODO: Put correct link
    
    Response response;
    try {
      response = await post(url, body: image);
    } catch(e) {
      print(e);
      await handleError(context);
      return;
    }

    if(response?.statusCode != 200) {
      await handleError(context);
      return;
    }
    else {
      await database.addPhotoKey(response.body);
    }
    
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> handleError(BuildContext context) async {
    await showDialog<void>(
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
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
