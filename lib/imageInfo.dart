import 'package:flutter/material.dart';
import 'package:trushot/tileData.dart';

class ImageInfoScreen extends StatelessWidget {
  final TileData data;

  ImageInfoScreen(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Hero(
                  tag: data.key,
                  child: Image(
                    image: data.file,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 10,),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: 'Key: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: data.key),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: BackButton(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}