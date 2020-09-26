import 'package:flutter/material.dart';
import 'package:trushot/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruShot',
      theme: ThemeData(
        primaryColor: Color(0xFF6C63FF),
        accentColor: Color(0xFF36344A),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
