import 'package:dsm_helper/widgets/neu_back_button.dart';
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
        leading: AppBackButton(context),
        title: Text("速度限制"),
      ),
      body: Center(
        child: Text("开发中……"),
      ),
    );
  }
}
