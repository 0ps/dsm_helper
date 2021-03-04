import 'package:flutter/material.dart';

class PhotoStation extends StatefulWidget {
  @override
  _PhotoStationState createState() => _PhotoStationState();
}

class _PhotoStationState extends State<PhotoStation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo Station"),
      ),
    );
  }
}
