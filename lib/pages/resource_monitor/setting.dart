import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/material.dart';

class MonitorSetting extends StatefulWidget {
  @override
  _MonitorSettingState createState() => _MonitorSettingState();
}

class _MonitorSettingState extends State<MonitorSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("设置"),
      ),
      body: Center(
        child: Text("开发中……"),
      ),
    );
  }
}
