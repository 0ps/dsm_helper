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
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: NeuButton(
                        onPressed: () async {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Material(
                                color: Colors.transparent,
                                child: NeuCard(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(22),
                                  bevel: 5,
                                  curveType: CurveType.emboss,
                                  decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "确认关机",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        "确认要关闭设备吗？",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        height: 22,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                var init = await Api.power("shutdown");
                                                if (init['success']) {
                                                  Util.toast("已发送指令");
                                                }
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "确认删除",
                                                style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "取消",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 20,
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/icons/shutdown.png",
                              width: 50,
                            ),
                            Text(
                              "关机",
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: NeuButton(
                        onPressed: () async {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Material(
                                color: Colors.transparent,
                                child: NeuCard(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(22),
                                  bevel: 5,
                                  curveType: CurveType.emboss,
                                  decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "确认重启",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        "确认要重新启动设备？",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        height: 22,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                var init = await Api.power("reboot");
                                                if (init['success']) {
                                                  Util.toast("已发送指令");
                                                }
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "确认删除",
                                                style: TextStyle(fontSize: 18, color: Colors.redAccent),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16,
                                          ),
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "取消",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: NeumorphicDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        bevel: 20,
                        child: Column(
                          children: [
                            Image.asset(
                              "assets/icons/reboot.png",
                              width: 50,
                            ),
                            Text(
                              "重启",
                              style: TextStyle(fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
