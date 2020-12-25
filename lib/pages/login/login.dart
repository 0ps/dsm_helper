import 'dart:convert';

import 'package:dsm_helper/util/api.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String host = "";
  String account = "";
  String password = "";
  String port = "5000";
  bool https = false;
  bool login = false;
  bool rememberPassword = true;
  bool autoLogin = true;
  TextEditingController _hostController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  List servers = [];
  @override
  initState() {
    _portController.value = TextEditingValue(text: port);
    getInfo();
    super.initState();
  }

  getInfo() async {
    String https = await Util.getStorage("https");
    String host = await Util.getStorage("host");
    String port = await Util.getStorage("port");
    String account = await Util.getStorage("account");
    String password = await Util.getStorage("password");
    String autoLogin = await Util.getStorage("auto_login");
    String rememberPassword = await Util.getStorage("remember_password");
    String serverString = await Util.getStorage("servers");
    if (serverString.isNotBlank) {
      servers = jsonDecode(serverString);
    }
    if (https.isNotBlank) {
      setState(() {
        this.https = https == "1";
      });
    }
    if (host.isNotBlank) {
      this.host = host;
      _hostController.value = TextEditingValue(text: host);
    }
    if (port.isNotBlank) {
      this.port = port;
      _portController.value = TextEditingValue(text: port);
    }
    if (account.isNotBlank) {
      this.account = account;
      _accountController.value = TextEditingValue(text: account);
    }
    if (password.isNotBlank) {
      this.password = password;
      _passwordController.value = TextEditingValue(text: password);
    }
    if (autoLogin.isNotBlank) {
      setState(() {
        this.autoLogin = autoLogin == "1";
      });
    }
    if (rememberPassword.isNotBlank) {
      setState(() {
        this.rememberPassword = rememberPassword == "1";
      });
    }
  }

  _login() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (login == true) {
      return;
    }
    if (host.trim() == "") {
      Util.toast("请输入网址/IP");
      return;
    }
    if (account == "") {
      Util.toast("请输入账号");
      return;
    }
    if (password == "") {
      Util.toast("请输入密码");
      return;
    }
    String baseUri = "${https ? "https" : "http"}://${host.trim()}:${port.trim()}";
    setState(() {
      login = true;
    });
    Util.cookie = "";
    var res = await Api.login(host: baseUri, account: account, password: password);
    setState(() {
      login = false;
    });
    if (res['success'] == true) {
      //记住登录信息

      Util.setStorage("https", https ? "1" : "0");
      Util.setStorage("host", host.trim());
      Util.setStorage("port", port);
      Util.setStorage("account", account);
      Util.setStorage("remember_password", rememberPassword ? "1" : "0");
      Util.setStorage("auto_login", autoLogin ? "1" : "0");
      Util.sid = res['data']['sid'];
      if (rememberPassword) {
        Util.setStorage("password", password);
      } else {
        Util.removeStorage("password");
      }
      if (autoLogin) {
        Util.setStorage("sid", res['data']['sid']);
      }

      Util.baseUrl = baseUri;

      //添加服务器记录
      bool exist = false;
      for (int i = 0; i < servers.length; i++) {
        if (servers[i]['https'] == https && servers[i]['host'] == host && servers[i]['port'] == port && servers[i]['account'] == account) {
          print("账号已存在，更新信息");
          if (rememberPassword) {
            servers[i]['password'] = password;
          } else {
            servers[i]['password'] = "";
          }

          servers[i]['remember_password'] = rememberPassword;
          servers[i]['auto_login'] = autoLogin;
          exist = true;
        }
      }
      if (!exist) {
        print("账号不存在");
        Map server = {
          "https": https,
          "host": host,
          "port": port,
          "account": account,
          "remember_password": rememberPassword,
          "auto_login": autoLogin,
        };
        if (rememberPassword) {
          server['password'] = password;
        } else {
          server['password'] = "";
        }
        servers.add(server);
      }
      Util.setStorage("servers", jsonEncode(servers));
      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    } else {
      if (res['error']['code'] == 400) {
        Util.toast("用户名/密码有误");
      } else {
        Util.toast("登录失败，code:${res['error']['code']}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "群辉助手",
          style: Theme.of(context).textTheme.headline6,
        ),
        brightness: Brightness.light,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: servers.length > 0
            ? [
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
                      setState(() {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return Material(
                              color: Colors.transparent,
                              child: NeuCard(
                                width: double.infinity,
                                bevel: 5,
                                curveType: CurveType.emboss,
                                decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "选择账号",
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ...servers.map((server) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child: NeuButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              print(server);
                                              // return;
                                              setState(() {
                                                https = server['https'];
                                                host = server['host'];
                                                _hostController.value = TextEditingValue(text: host);
                                                port = server['port'];
                                                _portController.value = TextEditingValue(text: port);
                                                account = server['account'];
                                                _accountController.value = TextEditingValue(text: account);
                                                password = server['password'];
                                                _passwordController.value = TextEditingValue(text: password);
                                                autoLogin = server['auto_login'];
                                                rememberPassword = server['remember_password'];
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

                                                      Util.setStorage("servers", jsonEncode(servers));
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
                                      }).toList(),
                                      NeuButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                        },
                                        decoration: NeumorphicDecoration(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        bevel: 20,
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
                              ),
                            );
                          },
                        );
                      });
                    },
                    child: Image.asset(
                      "assets/icons/history.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                )
              ]
            : null,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              curveType: CurveType.flat,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          https = !https;
                          if (https && port == "5000") {
                            port = "5001";
                            _portController.value = TextEditingValue(text: port);
                          } else if (!https && port == "5001") {
                            port = "5000";
                            _portController.value = TextEditingValue(text: port);
                          }
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "协议",
                            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1),
                          ),
                          Text(
                            https ? "https" : "http",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: NeuTextField(
                      controller: _hostController,
                      onChanged: (v) => host = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '网址/IP',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: NeuTextField(
                      onChanged: (v) => port = v,
                      controller: _portController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '端口',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 20,
              curveType: CurveType.flat,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: NeuTextField(
                controller: _accountController,
                onChanged: (v) => account = v,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '账号',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            NeuCard(
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              bevel: 12,
              curveType: CurveType.flat,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: NeuTextField(
                controller: _passwordController,
                onChanged: (v) => password = v,
                obscureText: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: '密码',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        rememberPassword = !rememberPassword;
                        if (!rememberPassword) {
                          autoLogin = false;
                        }
                      });
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      curveType: rememberPassword ? CurveType.emboss : CurveType.flat,
                      bevel: 12,
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Row(
                        children: [
                          Text("记住密码"),
                          Spacer(),
                          if (rememberPassword)
                            Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xffff9813),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        autoLogin = !autoLogin;
                        if (autoLogin) {
                          rememberPassword = true;
                        }
                      });
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      curveType: autoLogin ? CurveType.emboss : CurveType.flat,
                      bevel: 12,
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Row(
                        children: [
                          Text("自动登录"),
                          Spacer(),
                          if (autoLogin)
                            Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xffff9813),
                            ),
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
            // SizedBox(
            //   height: 20,
            // ),
            NeuButton(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: NeumorphicDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: _login,
              child: login
                  ? Center(
                      child: CupertinoActivityIndicator(
                        radius: 13,
                      ),
                    )
                  : Text(
                      ' 登录 ',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
