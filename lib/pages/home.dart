import 'package:file_station/pages/file/file.dart';
import 'package:file_station/pages/setting/setting.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        children: [
          Files(),
          Files(),
          Files(),
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
          1: Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Image.asset(
                  "assets/tabbar/star.png",
                  width: 30,
                  height: 30,
                ),
                Text(
                  "收藏",
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
