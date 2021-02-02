import 'package:flutter/material.dart';

class UserSetting extends StatefulWidget {
  @override
  _UserSettingState createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("个人设置"),
      ),
    );
  }
}
