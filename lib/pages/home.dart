import 'dart:io';

import 'package:dsm_helper/pages/dashborad/dashboard.dart';
import 'package:dsm_helper/pages/download/download.dart';
import 'package:dsm_helper/pages/file/file.dart';
import 'package:dsm_helper/pages/setting/setting.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neumorphic/neumorphic.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  DateTime lastPopTime;
  GlobalKey<FilesState> _filesStateKey = GlobalKey<FilesState>();
  GlobalKey<DashboardState> _dashboardStateKey = GlobalKey<DashboardState>();
  @override
  void initState() {
    super.initState();
  }

  Future<bool> onWillPop() {
    if (_dashboardStateKey.currentState.isDrawerOpen) {
      print("open");
      _dashboardStateKey.currentState.closeDrawer();
      return Future.value(false);
    }
    Future<bool> value = Future.value(true);
    if (_currentIndex == 1) {
      value = _filesStateKey.currentState.onWillPop();
    }
    value.then((v) {
      if (v) {
        if (lastPopTime == null || DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
          lastPopTime = DateTime.now();
          Util.toast('再按一次退出群辉助手');
        } else {
          lastPopTime = DateTime.now();
          // 退出app
          SystemNavigator.pop();
        }
      }
    });
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: null,
        body: IndexedStack(
          children: [
            Dashboard(
              key: _dashboardStateKey,
            ),
            Files(
              key: _filesStateKey,
            ),
            Download(key: Util.downloadKey),
            Setting(),
          ],
          index: _currentIndex,
        ),
        bottomNavigationBar: NeuSwitch(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          thumbColor: Theme.of(context).scaffoldBackgroundColor,
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
      ),
    );
  }
}
