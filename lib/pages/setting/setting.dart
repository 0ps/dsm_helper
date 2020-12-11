import 'package:dsm_helper/pages/setting/about.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool checking = false;
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
      body: Column(
        children: [
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: NeuButton(
              onPressed: () {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                  return About();
                }));
              },
              // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              child: Text(
                "关于群晖助手",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: NeuButton(
              onPressed: () {
                Util.removeStorage("sid");
                Util.removeStorage("smid");
                Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
              },
              // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              child: Text(
                "退出登录",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
