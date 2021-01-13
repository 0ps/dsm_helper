import 'package:flutter/material.dart';

class SpeedLimit extends StatefulWidget {
  @override
  _SpeedLimitState createState() => _SpeedLimitState();
}

class _SpeedLimitState extends State<SpeedLimit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("速度限制"),
      ),
      body: Center(
        child: Text("开发中……"),
      ),
    );
  }
}
