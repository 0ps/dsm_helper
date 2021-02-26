import 'dart:async';
import 'dart:convert';

import 'package:dsm_helper/pages/login/login.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:dsm_helper/widgets/label.dart';
import 'package:dsm_helper/widgets/neu_back_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Accounts extends StatefulWidget {
  @override
  _AccountsState createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List servers = [];
  Timer timer;
  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  getData() async {
    String serverString = await Util.getStorage("servers");
    if (serverString.isNotBlank) {
      setState(() {
        servers = json.decode(serverString);
      });
      getInfo();
    }
  }

  getInfo() async {
    if (timer == null) {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        getInfo();
      });
    }
    servers.forEach((server) {
      server['loading'] = server['loading'] ?? true;
      server['is_login'] = server['is_login'] ?? false;
      server['base_url'] = server['base_url'] ?? "${server['https'] ? "https" : "http"}://${server['host']}:${server['port']}/";
      if (server['is_login']) {
        serverInfo(server);
      } else {
        //仅首次重新登录
        if (server['loading']) {
          String host = server['base_url'];
          print(host);
          Api.shareList(sid: server['sid'], checkSsl: server['check_ssl'], cookie: server['smid'], host: host).then((checkLogin) async {
            if (checkLogin['success']) {
              server['is_login'] = true;
              print("登录有效");
              //获取系统信息
              serverInfo(server);
            } else {
              //登录失败，尝试重新登录
              var res = await Api.login(host: host, account: server['account'], password: server['password'], otpCode: "", rememberDevice: false, cookie: server['smid']);
              if (res['success']) {
                print("重新登录成功");
                setState(() {
                  server['is_login'] = true;
                });
                server['sid'] = res['data']['sid'];
                saveAccounts();
                serverInfo(server);
              } else {
                setState(() {
                  server['loading'] = false;
                });
              }
            }
          });
        }
      }
    });
  }

  saveAccounts() async {
    List accounts = [];
    servers.forEach((server) {
      accounts.add({
        "https": server['https'],
        "host": server['host'],
        "base_url": server['base_url'],
        "port": server['port'],
        "account": server['account'],
        "remember_password": server['remember_password'],
        "password": server['password'],
        "auto_login": server['auto_login'],
        "check_ssl": server['check_ssl'],
        "cookie": server['cookie'],
        "sid": server['sid'],
      });
    });
    Util.setStorage("servers", json.encode(accounts));
  }

  serverInfo(server) async {
    var res = await Api.utilization(sid: server['sid'], checkSsl: server['check_ssl'], cookie: server['smid'], host: "${server['base_url']}");
    if (res['success']) {
      if (!mounted) {
        return;
      }
      setState(() {
        server['cpu'] = (res['data']['cpu']['user_load'] + res['data']['cpu']['system_load']);
        server['ram'] = res['data']['memory']['real_usage'];
        if (res['data']['network'].length > 0) {
          server['rx'] = res['data']['network'][0]['rx'];
          server['tx'] = res['data']['network'][0]['tx'];
        }
        if (res['data']['disk']['total'] != null) {
          server['read'] = res['data']['disk']['total']['read_byte'];
          server['write'] = res['data']['disk']['total']['write_byte'];
        }

        server['loading'] = false;
      });
    }
  }

  Widget _buildServerItem(server) {
    server['loading'] = server['loading'] ?? true;
    server['cpu'] = server['cpu'] ?? 0.0;
    server['ram'] = server['ram'] ?? 0.0;
    server['tx'] = server['tx'] ?? 0.0;
    server['rx'] = server['rx'] ?? 0.0;
    server['read'] = server['read'] ?? 0.0;
    server['write'] = server['write'] ?? 0.0;
    return GestureDetector(
      onTap: () {
        if (server['is_login']) {
          Util.baseUrl = "${server['base_url']}";
          Util.checkSsl = server['check_ssl'];
          Util.setStorage("https", server['https'] ? "1" : "0");
          Util.setStorage("host", server['host']);
          Util.setStorage("port", server['port']);
          Util.setStorage("account", server['account']);
          Util.setStorage("remember_password", server['remember_password'] ? "1" : "0");
          Util.setStorage("auto_login", server['auto_login'] ? "1" : "0");
          Util.setStorage("check_ssl", server['check_ssl'] ? "1" : "0");
          Util.setStorage("sid", server['sid']);
          Util.sid = server['sid'];
          Util.cookie = server['smid'];
          Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
        } else {
          server['action'] = "login";
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return Login(server: server);
          }));
        }
      },
      child: NeuCard(
        curveType: CurveType.flat,
        decoration: NeumorphicDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        bevel: 20,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${server['account']}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Label(server['https'] ? "https" : "http", server['https'] ? Colors.green : Colors.lightBlueAccent),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "${server['host']}",
                                style: TextStyle(color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        if (server['loading']) CupertinoActivityIndicator() else if (!server['is_login']) Label("登录失效", Colors.red),
                        SizedBox(
                          width: 10,
                        ),
                        NeuButton(
                          onPressed: () {
                            print(server);
                            server['action'] = "edit";
                            Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                              return Login(server: server);
                            }));
                          },
                          decoration: NeumorphicDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          bevel: 20,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Image.asset(
                            "assets/icons/edit.png",
                            width: 20,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        NeuButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() {
                              servers.remove(server);
                            });

                            saveAccounts();
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
                    Row(
                      children: [
                        Column(
                          children: [
                            NeuCard(
                              curveType: CurveType.flat,
                              margin: EdgeInsets.only(top: 10, right: 10),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(60),
                                // color: Colors.red,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              bevel: 8,
                              child: CircularPercentIndicator(
                                radius: 60,
                                // progressColor: Colors.lightBlueAccent,
                                animation: true,
                                linearGradient: LinearGradient(
                                  colors: server['cpu'] <= 90
                                      ? [
                                          Colors.blue,
                                          Colors.blueAccent,
                                        ]
                                      : [
                                          Colors.red,
                                          Colors.orangeAccent,
                                        ],
                                ),
                                animateFromLastPercent: true,
                                circularStrokeCap: CircularStrokeCap.round,
                                lineWidth: 8,
                                backgroundColor: Colors.black12,
                                percent: server['cpu'] / 100,
                                center: server['loading']
                                    ? CupertinoActivityIndicator()
                                    : Text(
                                        "${server['cpu']}%",
                                        style: TextStyle(color: server['cpu'] <= 90 ? Colors.blue : Colors.red, fontSize: 16),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("CPU"),
                          ],
                        ),
                        Column(
                          children: [
                            NeuCard(
                              curveType: CurveType.flat,
                              margin: EdgeInsets.only(top: 10, right: 10),
                              decoration: NeumorphicDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(60),
                                // color: Colors.red,
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              bevel: 8,
                              child: CircularPercentIndicator(
                                radius: 60,
                                // progressColor: Colors.lightBlueAccent,
                                animation: true,
                                linearGradient: LinearGradient(
                                  colors: server['ram'] <= 90
                                      ? [
                                          Colors.blue,
                                          Colors.blueAccent,
                                        ]
                                      : [
                                          Colors.red,
                                          Colors.orangeAccent,
                                        ],
                                ),
                                animateFromLastPercent: true,
                                circularStrokeCap: CircularStrokeCap.round,
                                lineWidth: 8,
                                backgroundColor: Colors.black12,
                                percent: server['ram'] / 100,
                                center: server['loading']
                                    ? CupertinoActivityIndicator()
                                    : Text(
                                        "${server['ram']}%",
                                        style: TextStyle(color: server['ram'] <= 90 ? Colors.blue : Colors.red, fontSize: 16),
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("RAM"),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 85,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.upload_sharp,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                        Text(
                                          "${server['loading'] ? "-" : "${Util.formatSize(server['tx'], fixed: 0)}/S"}",
                                          style: TextStyle(color: Colors.blue, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.download_sharp,
                                          color: Colors.green,
                                          size: 16,
                                        ),
                                        Text(
                                          "${server['loading'] ? "-" : "${Util.formatSize(server['rx'], fixed: 0)}/S"}",
                                          style: TextStyle(color: Colors.green, fontSize: 12),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Text("网络"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 85,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "R:${server['loading'] ? "-" : "${Util.formatSize(server['read'], fixed: 0)}/S"}",
                                      style: TextStyle(color: Colors.blue, fontSize: 12),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "W:${server['loading'] ? "-" : "${Util.formatSize(server['write'], fixed: 0)}/S"}",
                                      style: TextStyle(color: Colors.green, fontSize: 12),
                                    )
                                  ],
                                ),
                              ),
                              Text("磁盘"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBackButton(context),
        title: Text("选择账号"),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20),
        itemBuilder: (context, i) {
          return _buildServerItem(servers[i]);
        },
        itemCount: servers.length,
        separatorBuilder: (context, i) {
          return SizedBox(
            height: 20,
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.refresh),
      //   onPressed: () {
      //     getInfo();
      //   },
      // ),
    );
  }
}
