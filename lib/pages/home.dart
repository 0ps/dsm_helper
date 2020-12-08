import 'package:dsm_helper/pages/dashborad/dashboard.dart';
import 'package:dsm_helper/pages/download/download.dart';
import 'package:dsm_helper/pages/favorite/favorite.dart';
import 'package:dsm_helper/pages/file/file.dart';
import 'package:dsm_helper/pages/setting/setting.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [
          Dashboard(),
          Files(),
          Download(key: Util.downloadKey),
          Setting(),
        ],
        index: _currentIndex,
      ),
      bottomNavigationBar: NeuSwitch(
        backgroundColor: Colors.white,
        thumbColor: Colors.white,
        // padding: EdgeInsets.symmetric(vertical: 5),
        onValueChanged: (v) {
          setState(() {
            _currentIndex = v;
          });
        },
        groupValue: _currentIndex,
        children: {
          0: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Image.asset(
                  "assets/tabbar/meter.png",
                  width: 30,
                  height: 30,
                ),
                Text(
                  "控制台",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Image.asset(
                  "assets/tabbar/folder.png",
                  width: 30,
                  height: 30,
                ),
                Text(
                  "文件",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          2: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Image.asset(
                  "assets/tabbar/save.png",
                  width: 30,
                  height: 30,
                ),
                Text(
                  "下载",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          3: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Image.asset(
                  "assets/tabbar/setting.png",
                  width: 30,
                  height: 30,
                ),
                Text(
                  "设置",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
