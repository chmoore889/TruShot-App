import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trushot/database.dart';
import 'package:trushot/gridImage.dart';
import 'package:trushot/tileData.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database database;
  Future<List<TileData>> photosFuture;

  @override
  void initState() {
    super.initState();
    database = Database();
    photosFuture = getPhotoData();
  }

  Future<List<TileData>> getPhotoData() async {
    List<TileData> toReturn = List();

    List<String> photoKeys = (await database.getPhotoKeys()) ?? [];
    final String path = (await getApplicationDocumentsDirectory()).path;

    List<Future<DateTime>> creationsFutures = [];
    List<File> files = [];
    for(String key in photoKeys) {
      File file = File('$path/$key');
      creationsFutures.add(file.lastModified());
      files.add(file);
    }
    List<DateTime> creations = await Future.wait(creationsFutures);
    for(int x = 0; x < photoKeys.length; x++) {
      toReturn.add(
        TileData(
          key: photoKeys[x],
          file: files[x],
          creationTime: creations[x],
        )
      );
    }

    toReturn.sort((a, b) {
      return b.creationTime.compareTo(a.creationTime);
    });

    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<TileData>>(
        future: photosFuture,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return getPhotosLists(snapshot.data);
          }
          else if(snapshot.hasError) {
            print(snapshot.error);
          }
          return Center(
            child: OrientationBuilder(
              builder: (context, orientation) {
                if(orientation == Orientation.portrait) {
                  double width = MediaQuery.of(context).size.width/2;
                  return SizedBox(
                    height: width,
                    width: width,
                    child: CircularProgressIndicator(),
                  );
                }
                double height = MediaQuery.of(context).size.height/2;
                return SizedBox(
                  height: height,
                  width: height,
                  child: CircularProgressIndicator(),
                );
              }
            )
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getNewImage();
        },
        tooltip: 'Take picture',
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFF6C63FF),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget getPhotosLists(List<TileData> photoData) {
    photoData = photoData ?? [];

    if(photoData.length == 0) {
      return Center(
        child: OrientationBuilder(
          builder: (context, orientation) {
            Axis mainDirection;
            if(orientation == Orientation.portrait) {
              mainDirection = Axis.vertical;
            }
            else {
              mainDirection = Axis.horizontal;
            }
            return Flex(
              direction: mainDirection,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/empty.png',
                  fit: BoxFit.contain,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'It\'s a bit lonely here',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    RaisedButton(
                      onPressed: () {
                        getNewImage();
                      },
                      child: Text(
                        'Take a photo'
                      ),
                    )
                  ],
                ),
              ],
            );
          }
        ),
      );
    }

    const int columnCount = 2;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
      ),
      itemCount: photoData.length,
      itemBuilder: (context, index) {
        if(index < photoData.length) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: columnCount,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: GridImage(photoData[index], () async {
                  await database.deletePhoto(photoData[index].key);
                  final String path = (await getApplicationDocumentsDirectory()).path;
                  File('$path/${photoData[index].key}').delete();
                  setState(() {
                    photosFuture = getPhotoData();
                  });
                }),
              ),
            ),
          );
        }
        return null;
      },
    );
  }

  Future<void> getNewImage() async {
    setState(() {
      photosFuture = Future.value();
    });

    final ImagePicker picker = ImagePicker();
    final PickedFile pickedFile = await picker.getImage(source: ImageSource.camera);

    if(pickedFile == null) {
      setState(() {
        photosFuture = getPhotoData();
      });
      return;
    }

    final Uint8List imageData = await pickedFile.readAsBytes();
    await handleKeep(context, imageData);

    setState(() {
      photosFuture = getPhotoData();
    });
  }

  Future<void> handleKeep(BuildContext context, Uint8List image) async {
    const String url = 'https://trushot.uk.r.appspot.com/upload';
    
    StreamedResponse response;
    try {
      final Uri uri = Uri.parse(url);
      final MultipartRequest request = MultipartRequest('POST', uri);
      request.fields['file'] = base64Encode(image);
      //print(base64Encode(image));
      response = await request.send();
    } catch(e) {
      print(e);
      await handleError(context);
      return;
    }

    if(response?.statusCode != 200) {
      print(response?.statusCode);
      print(await response?.stream?.bytesToString());
      await handleError(context);
      return;
    }
    else {
      String keyForImage = jsonDecode(await response.stream.bytesToString())['detail'];
      await database.addPhotoKey(keyForImage);

      final String path = (await getApplicationDocumentsDirectory()).path;
      await File('$path/$keyForImage').writeAsBytes(image, flush: true);
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
