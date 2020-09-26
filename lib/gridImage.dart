import 'package:feather_icons_flutter/feather_icons_flutter.dart';
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
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      child: Stack(
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
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.all(10),
                child: Hero(
                  tag: code.key,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: code.file,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              iconSize: 20,
              icon: Icon(FeatherIcons.trash2),
              onPressed: handleDeletion,
              color: Colors.red
            ),
          ),
        ],
      ),
    );
  }
}