import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trushot/constants.dart';
import 'package:trushot/database.dart';
import 'package:trushot/imageInfo.dart';
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
    for (String key in photoKeys) {
      File file = File('$path/$key');
      creationsFutures.add(file.lastModified());
      files.add(file);
    }
    List<DateTime> creations = await Future.wait(creationsFutures);
    for (int x = 0; x < photoKeys.length; x++) {
      toReturn.add(TileData(
        key: photoKeys[x],
        file: files[x],
        creationTime: creations[x],
      ));
    }

    toReturn.sort((a, b) {
      return b.creationTime.compareTo(a.creationTime);
    });

    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<TileData>>(
            future: photosFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return getPhotosLists(snapshot.data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
              }
              return Center(
                  child: OrientationBuilder(builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  double width = MediaQuery.of(context).size.width / 2;
                  return SizedBox(
                    height: width,
                    width: width,
                    child: CircularProgressIndicator(),
                  );
                }
                double height = MediaQuery.of(context).size.height / 2;
                return SizedBox(
                  height: height,
                  width: height,
                  child: CircularProgressIndicator(),
                );
              }));
            }),
      ),
      backgroundColor: backgroundColor,
    );
  }

  Widget getPhotosLists(List<TileData> photoData) {
    photoData = photoData ?? [];

    if (photoData.length == 0) {
      return Center(
        child: OrientationBuilder(builder: (context, orientation) {
          Axis mainDirection;
          if (orientation == Orientation.portrait) {
            mainDirection = Axis.vertical;
          } else {
            mainDirection = Axis.horizontal;
          }
          return Flex(
            direction: mainDirection,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (mainDirection == Axis.vertical)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 5),
                        child: Icon(
                          FeatherIcons.aperture,
                          size: 32,
                          color: textColor,
                        ),
                      ),
                      Text(
                        "TruShot",
                        style: GoogleFonts.nunito(
                            color: textColor,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/polaroid.png',
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: mainDirection == Axis.vertical
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 15.0),
                      child: Text('It\'s a bit lonely here',
                          style: GoogleFonts.nunito(
                              color: textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.w400)),
                    ),
                    GestureDetector(
                      onTap: () => getNewImage(),
                      child: Container(
                        width: mainDirection == Axis.vertical
                            ? MediaQuery.of(context).size.width * .5
                            : MediaQuery.of(context).size.width * .3,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 10.0,
                                  color: accentColor.withOpacity(0.70))
                            ]),
                        child: Center(
                          child: Text(
                            "Take a picture",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                                color: textColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      );
    }

    void copyToClipboard(String input, BuildContext context) {
      Clipboard.setData(ClipboardData(text: input));
      Scaffold.of(context).showSnackBar(SnackBar(
        content: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: input, style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: ' copied to clipboard'),
            ],
          ),
        ),
      ));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
      ),
      itemCount: photoData.length,
      itemBuilder: (context, index) {
        if (index < photoData.length) {
          final TileData code = photoData[index];

          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ImageInfoScreen(code);
              }));
            },
            onLongPress: () async {
              await Feedback.forLongPress(context);
              copyToClipboard(code.key, context);
            },
            child: Hero(
              tag: code.key,
              child: Image.file(
                code.file,
                fit: BoxFit.cover,
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
    final PickedFile pickedFile =
        await picker.getImage(source: ImageSource.camera);

    if (pickedFile == null) {
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
    } catch (e) {
      print(e);
      await handleError(context);
      return;
    }

    if (response?.statusCode != 200) {
      print(response?.statusCode);
      print(await response?.stream?.bytesToString());
      await handleError(context);
      return;
    } else {
      String keyForImage =
          jsonDecode(await response.stream.bytesToString())['detail'];
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
