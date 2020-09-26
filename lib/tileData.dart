import 'dart:io';

class TileData {
  final String key;
  final DateTime creationTime;
  final File file;

  TileData({this.key, this.creationTime, this.file});
}