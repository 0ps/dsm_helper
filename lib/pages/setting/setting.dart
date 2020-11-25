import 'package:file_station/util/function.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "设置",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(),
      persistentFooterButtons: [
        Container(
          width: MediaQuery.of(context).size.width - 16,
          height: 50,
          child: NeuButton(
            onPressed: () {
              Util.removeStorage("sid");
              Util.removeStorage("host");
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            },
            // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: NeumorphicDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text("退出登录"),
          ),
        )
      ],
    );
  }
}
