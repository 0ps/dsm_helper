import 'dart:convert';
import 'dart:io';

import 'package:dsm_helper/pages/backup/backup.dart';
import 'package:dsm_helper/pages/control_panel/ssh/ssh.dart';
import 'package:dsm_helper/pages/login/accounts.dart';
import 'package:dsm_helper/pages/login/confirm_logout.dart';
import 'package:dsm_helper/pages/provider/dark_mode.dart';
import 'package:dsm_helper/pages/setting/helper_setting.dart';
import 'package:dsm_helper/pages/terminal/select_server.dart';
import 'package:dsm_helper/pages/user/setting.dart';
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

  List servers = [];

  String account = "";

  bool otpEnable = false;
  bool otpEnforced = false;
  String email = "";

  Widget _buildServerItem(server) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: NeuButton(
        onPressed: () async {
          Navigator.of(context).pop();
          // return;
          setState(() {
            // https = server['https'];
            // host = server['host'];
            // _hostController.value = TextEditingValue(text: host);
            // port = server['port'];
            // _portController.value = TextEditingValue(text: port);
            // account = server['account'];
            // _accountController.value = TextEditingValue(text: account);
            // password = server['password'];
            // _passwordController.value = TextEditingValue(text: password);
            // autoLogin = server['auto_login'];
            // rememberPassword = server['remember_password'];
            // checkSsl = server['check_ssl'] ?? true;
            // Util.cookie = server['cookie'];
          });
        },
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.zero,
        bevel: 20,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${server['account']}",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${server['https'] ? "https" : "http"}://${server['host']}:${server['port']}",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              NeuButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    servers.remove(server);
                  });

                  Util.setStorage("servers", json.encode(servers));
                  Util.toast("删除成功");
                },
                decoration: NeumorphicDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                bevel: 20,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Image.asset(
                  "assets/icons/delete.png",
                  width: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    getData();
    getServers();
    getNormalUser();
    Util.getStorage("account").then((value) => setState(() => account = value));
    super.initState();
  }

  getServers() async {
    String serverString = await Util.getStorage("servers");
    if (serverString.isNotBlank) {
      servers = json.decode(serverString);
    }
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

  getNormalUser() async {
    var res = await Api.normalUser("get");
    if (res['success']) {
      setState(() {
        otpEnable = res['data']['OTP_enable'];
        otpEnforced = res['data']['OTP_enforced'];
        email = res['data']['email'];
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
                              power(type, true);
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
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10, top: 8, bottom: 8),
            child: NeuButton(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              bevel: 5,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return HelperSetting();
                    },
                    settings: RouteSettings(name: "helper_setting"),
                  ),
                );
              },
              child: Image.asset(
                "assets/icons/setting.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
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
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(CupertinoPageRoute(
                            builder: (context) {
                              return UserSetting();
                            },
                            settings: RouteSettings(name: "user_setting")))
                        .then((res) {
                      if (res != null && res) {
                        getNormalUser();
                      }
                    });
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage("assets/logo.png"),
                            radius: 30,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$account",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                ),
                                if (email.isNotEmpty) ...[
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "$email",
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ],
                            ),
                          ),
                          NeuButton(
                            onPressed: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) {
                                  return ConfirmLogout(otpEnable);
                                },
                              );
                            },
                            // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            bevel: 20,
                            child: Image.asset(
                              "assets/icons/exit.png",
                              width: 16,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          NeuButton(
                            onPressed: () {
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return Accounts();
                              }));
                            },
                            // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            padding: EdgeInsets.all(10),
                            decoration: NeumorphicDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            bevel: 20,
                            child: Image.asset(
                              "assets/icons/change.png",
                              width: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                        onLongPress: () {
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) {
                                return SshSetting();
                              },
                              settings: RouteSettings(name: "ssh_setting")));
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
                                "SSH${ssh == null ? "开关" : ssh ? "已开启" : "已关闭"}",
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
                          Navigator.of(context).push(CupertinoPageRoute(
                              builder: (context) {
                                return SelectServer();
                              },
                              settings: RouteSettings(name: "select_server")));
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
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Platform.isAndroid
                          ? NeuButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (context) {
                                      return Backup();
                                    },
                                    settings: RouteSettings(name: "backup")));
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
                                    "assets/icons/upload.png",
                                    width: 40,
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "相册备份",
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Expanded(
                //   child: ,
                // ),
                // SizedBox(
                //   width: 20,
                // ),
                // Expanded(
                //   child: NeuButton(
                //     onPressed: () {
                //       showCupertinoModalPopup(
                //         context: context,
                //         builder: (context) {
                //           return Material(
                //             color: Colors.transparent,
                //             child: NeuCard(
                //               width: double.infinity,
                //               height: MediaQuery.of(context).size.height * 0.8,
                //               bevel: 5,
                //               curveType: CurveType.emboss,
                //               decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                //               child: Padding(
                //                 padding: EdgeInsets.symmetric(vertical: 20),
                //                 child: Column(
                //                   mainAxisSize: MainAxisSize.min,
                //                   children: <Widget>[
                //                     Text(
                //                       "选择账号",
                //                       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                //                     ),
                //                     SizedBox(
                //                       height: 20,
                //                     ),
                //                     Expanded(
                //                       child: ListView.builder(
                //                         padding: EdgeInsets.all(20),
                //                         itemBuilder: (context, i) {
                //                           return _buildServerItem(servers[i]);
                //                         },
                //                         itemCount: servers.length,
                //                       ),
                //                     ),
                //                     Padding(
                //                       padding: EdgeInsets.symmetric(horizontal: 20),
                //                       child: NeuButton(
                //                         onPressed: () async {
                //                           Navigator.of(context).pop();
                //                         },
                //                         decoration: NeumorphicDecoration(
                //                           color: Theme.of(context).scaffoldBackgroundColor,
                //                           borderRadius: BorderRadius.circular(25),
                //                         ),
                //                         bevel: 20,
                //                         padding: EdgeInsets.symmetric(vertical: 10),
                //                         child: Text(
                //                           "取消",
                //                           style: TextStyle(fontSize: 18),
                //                         ),
                //                       ),
                //                     ),
                //                     SizedBox(
                //                       height: 8,
                //                     ),
                //                   ],
                //                 ),
                //               ),
                //             ),
                //           );
                //         },
                //       );
                //     },
                //     // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                //     padding: EdgeInsets.symmetric(vertical: 20),
                //     decoration: NeumorphicDecoration(
                //       color: Theme.of(context).scaffoldBackgroundColor,
                //       borderRadius: BorderRadius.circular(20),
                //     ),
                //     bevel: 20,
                //     child: Text(
                //       "切换账号",
                //       style: TextStyle(fontSize: 18),
                //     ),
                //   ),
                // )
              ],
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
