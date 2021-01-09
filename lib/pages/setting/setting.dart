import 'package:dsm_helper/pages/provider/dark_mode.dart';
import 'package:dsm_helper/pages/setting/about.dart';
import 'package:dsm_helper/pages/terminal/select_server.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool checking = false;
  bool ssh;
  bool telnet;

  bool sshLoading = true;
  bool shutdowning = false;
  bool rebooting = false;
  String sshPort;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    var res = await Api.terminalInfo();
    if (res['success']) {
      setState(() {
        ssh = res['data']['enable_ssh'];
        telnet = res['data']['enable_telnet'];
        sshPort = res['data']['ssh_port'].toString();
        sshLoading = false;
      });
    } else {
      setState(() {
        sshLoading = false;
        ssh = null;
      });
    }
  }

  power(String type, bool force) async {
    setState(() {
      if (type == "shutdown") {
        shutdowning = true;
      } else {
        rebooting = true;
      }
    });
    var res = await Api.power(type, force);
    setState(() {
      if (type == "shutdown") {
        shutdowning = false;
      } else {
        rebooting = false;
      }
    });
    if (res['success']) {
      Util.toast("已发送指令");
    } else if (res['error']['code'] == 117) {
      List errors = res['error']['errors']['runningTasks'];
      List msgs = [];
      for (int i = 0; i < errors.length; i++) {
        List titles = errors[i].split(":");
        if (titles.length == 3) {
          msgs.add(Util.strings[titles[0]][titles[1]][titles[2]]);
        }
        //系统正在处理下列任务。现在关机可能会导致套件异常或数据丢失。是否确定要继续？
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
                      "系统正在处理下列任务。现在关机可能会导致套件异常或数据丢失。是否确定要继续？",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "${msgs.join("\n")}",
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
                              power("shutdown", true);
                            },
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            bevel: 5,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "强制${type == "shutdown" ? "关机" : "重启"}",
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
      }
      print(msgs);
    } else {
      Util.toast("操作失败，code:${res['error']['code']}");
    }
  }

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
                          if (shutdowning) {
                            return;
                          }
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
                                                power("shutdown", false);
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "确认关机",
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
                            shutdowning
                                ? CupertinoActivityIndicator(
                                    radius: 20,
                                  )
                                : Image.asset(
                                    "assets/icons/shutdown.png",
                                    width: 40,
                                  ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "关机",
                              style: TextStyle(fontSize: 16),
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
                          if (rebooting) {
                            return;
                          }
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
                                                power("reboot", false);
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "确认重启",
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
                            rebooting
                                ? CupertinoActivityIndicator(
                                    radius: 20,
                                  )
                                : Image.asset(
                                    "assets/icons/reboot.png",
                                    width: 40,
                                  ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "重启",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (ssh == null) {
                            Util.toast("未获取到SSH状态，正在重试");
                            getData();
                          } else {
                            setState(() {
                              sshLoading = true;
                            });
                            await Api.setTerminal(!ssh, telnet, sshPort);
                            await getData();
                          }
                        },
                        child: NeuCard(
                          // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          curveType: ssh == null
                              ? CurveType.convex
                              : ssh
                                  ? CurveType.emboss
                                  : CurveType.flat,
                          bevel: 20,
                          child: Column(
                            children: [
                              sshLoading
                                  ? CupertinoActivityIndicator(
                                      radius: 20,
                                    )
                                  : Image.asset(
                                      "assets/icons/ssh.png",
                                      width: 40,
                                    ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "SSH开关",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
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
                                        "主题颜色",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: NeuButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                Provider.of<DarkModeProvider>(context, listen: false).changeMode(0);
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "亮色",
                                                style: TextStyle(fontSize: 18),
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
                                                Provider.of<DarkModeProvider>(context, listen: false).changeMode(1);
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "暗色",
                                                style: TextStyle(fontSize: 18),
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
                                                Provider.of<DarkModeProvider>(context, listen: false).changeMode(2);
                                              },
                                              decoration: NeumorphicDecoration(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              bevel: 5,
                                              padding: EdgeInsets.symmetric(vertical: 10),
                                              child: Text(
                                                "跟随系统",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      NeuButton(
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
                              "assets/icons/theme.png",
                              width: 40,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "主题颜色",
                              style: TextStyle(fontSize: 16),
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
                        onPressed: () {
                          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                            return SelectServer();
                          }));
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
                              "assets/icons/ssh.png",
                              width: 40,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "终端",
                              style: TextStyle(fontSize: 16),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    SizedBox(
                      width: 20,
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
