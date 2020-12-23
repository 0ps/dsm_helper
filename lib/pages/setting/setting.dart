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
  bool ssh;
  bool telnet;

  bool sshLoading = true;
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
                                "SSH",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.symmetric(horizontal: 20),
          //   child: NeuButton(
          //     onPressed: () async {
          //       String plainText = '我是shyandsy，never give up man';
          //       String key = '__cIpHeRtExT';
          //       String iv = '__cIpHeRtOkEn';
          //       String nonce = await Cipher2.generateNonce();
          //       String encryptedString = "U2FsdGVkX1/MEbBRiWWAahV1AgWEwAl9rtnz1hgMakjembP6jtsdnpxV1vxMREdOpEBNMx9SXTJT7IGRJu802p2s3VDs5+8yxkF5rdC1C3aBDA/bGWF0oZL/gg44Dmg3KKHmJBMvQqbNXnyO1jWvSpifcP0hA8t7mlp82bgNdXyHh0IYQh+9QVawyuxO84V+4IkO7yC1GbCJt7tcsHxFBihRj0CxRVTbZv/Lww3Xq3cdbW6dy9qjjx1dZkc9gvDwG5YIpE2VnJcPiLf7tsO23/y4Ekr+D00OPddcIvEuEFYY0s7++Ok9y7f6QRDmkAQIQu5NrPZhCP2m3c0yUfDYamfOeOt8TYeTonCHuDZs6+3v/lj4B+kHpjk8YnFfVOZ2EkHo3aTxodyQKddpUpw4GDbOpgm1zDL2V8rOZnbON06P6PSB7GEArWPcmjkALbzEt3Vvo65jByMu29xcnaDDz2wkft0MfLugNdhuCoBosJI=";
          //       String decryptedString = await Cipher2.decryptAesCbc128Padding7(encryptedString, key, iv);
          //       print(decryptedString);
          //     },
          //     // margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //     padding: EdgeInsets.symmetric(vertical: 20),
          //     decoration: NeumorphicDecoration(
          //       color: Theme.of(context).scaffoldBackgroundColor,
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     bevel: 20,
          //     child: Text(
          //       "测试",
          //       style: TextStyle(fontSize: 18),
          //     ),
          //   ),
          // ),
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
