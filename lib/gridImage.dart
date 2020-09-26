import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trushot/imageInfo.dart';
import 'package:trushot/tileData.dart';

class GridImage extends StatelessWidget {
  final TileData code;
  final VoidCallback handleDeletion;
  
  GridImage(this.code, this.handleDeletion);

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
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ImageInfoScreen(code);
                }
              ));
            },
            onLongPress: () async {
              await Feedback.forLongPress(context);
              copyToClipboard(code.key, context);
            },
            child: Hero(
              tag: code.key,
              child: Image(
                image: code.file,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: handleDeletion,
          ),
        ),
      ],
    );
  }
}