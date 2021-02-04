import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dsm_helper/pages/login/accounts.dart';
import 'package:dsm_helper/util/api.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:vibrate/vibrate.dart';

class Login extends StatefulWidget {
  final Map server;
  Login({this.server});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String host = "";
  String account = "";
  String password = "";
  String port = "5000";
  bool needOtp = false;
  String otpCode = "";
  String sid = "";
  String smid = "";
  bool https = false;
  bool login = false;
  bool rememberPassword = true;
  bool autoLogin = true;
  bool checkSsl = true;
  bool rememberDevice = false;
  TextEditingController _hostController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  List servers = [];
  CancelToken cancelToken = CancelToken();
  @override
  initState() {
    _portController.value = TextEditingValue(text: port);
    Util.getStorage("servers").then((serverString) {
      if (serverString.isNotBlank) {
        servers = jsonDecode(serverString);
      }
      if (widget.server != null) {
        print(widget.server);
        setState(() {
          https = widget.server['https'];
          host = widget.server['host'];
          port = widget.server['port'];
          account = widget.server['account'];
          password = widget.server['password'];
          autoLogin = widget.server['auto_login'];
          rememberPassword = widget.server['remember_password'];
          checkSsl = widget.server['check_ssl'];
          if (host.isNotBlank) {
            _hostController.value = TextEditingValue(text: host);
          }
          if (port.isNotBlank) {
            _portController.value = TextEditingValue(text: port);
          }
          if (account.isNotBlank) {
            _accountController.value = TextEditingValue(text: account);
          }
          print(password);
          if (password.isNotBlank) {
            _passwordController.value = TextEditingValue(text: password);
          }
        });
        Util.cookie = widget.server['cookie'];
        Util.sid = widget.server['sid'];
      } else {
        getInfo();
      }
    });

    super.initState();
  }

  getInfo() async {
    sid = await Util.getStorage("sid");
    smid = await Util.getStorage("smid");
    String httpsString = await Util.getStorage("https");
    host = await Util.getStorage("host");
    port = await Util.getStorage("port");
    account = await Util.getStorage("account");
    password = await Util.getStorage("password");
    String autoLoginString = await Util.getStorage("auto_login");

    String rememberPasswordString = await Util.getStorage("remember_password");
    String checkSslString = await Util.getStorage("check_ssl");
    Util.cookie = smid;

    if (httpsString.isNotBlank) {
      setState(() {
        https = httpsString == "1";
      });
    }
    if (checkSslString.isNotBlank) {
      setState(() {
        checkSsl = checkSslString == "1";
      });
    }
    if (host.isNotBlank) {
      _hostController.value = TextEditingValue(text: host);
    }
    if (port.isNotBlank) {
      _portController.value = TextEditingValue(text: port);
    }
    if (account.isNotBlank) {
      _accountController.value = TextEditingValue(text: account);
    }
    if (password.isNotBlank) {
      _passwordController.value = TextEditingValue(text: password);
    }
    if (autoLoginString.isNotBlank) {
      setState(() {
        autoLogin = autoLoginString == "1";
      });
    }
    if (rememberPasswordString.isNotBlank) {
      setState(() {
        rememberPassword = rememberPasswordString == "1";
      });
    }
  }

  checkLogin() async {
    if (https != null && sid.isNotBlank && host.isNotBlank) {
      //开始自动登录
      Util.baseUrl = "${https ? "https" : "http"}://$host:$port";
      Util.sid = sid;
      //如果开启了自动登录，则判断当前登录状态
      print("autoLogin:${autoLogin}");
      if (autoLogin) {
        setState(() {
          login = true;
        });
        var checkLogin = await Api.shareList(cancelToken: cancelToken);
        if (!checkLogin['success']) {
          if (checkLogin['code'] == "用户取消") {
            //如果用户主动取消登录
            setState(() {
              login = false;
            });
          } else {
            //如果登录失效，尝试重新登录
            _login();
            // var loginRes = await Api.login(host: Util.baseUrl, account: account, password: password, cancelToken: cancelToken, rememberDevice: false);
            // if (loginRes['success'] == true) {
            //   //重新登录成功
            //   Util.setStorage("sid", loginRes['data']['sid']);
            //   Util.sid = loginRes['data']['sid'];
            //   Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
            // } else {
            //   if (loginRes['code'] == "用户取消") {
            //     Util.toast("用户取消登录");
            //   } else {
            //     Util.toast("自动登录失败，请手动登录");
            //     Util.vibrate(FeedbackType.warning);
            //   }
            //
            //   setState(() {
            //     login = false;
            //   });
            // }
          }
        } else {
          //登录有效，进入首页
          Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
        }
      }
    }
  }

  _login() async {
    Util.checkSsl = checkSsl;
    FocusScope.of(context).requestFocus(FocusNode());
    if (login == true) {
      cancelToken?.cancel("取消登录");
      cancelToken = CancelToken();
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
    var res = await Api.login(host: baseUri, account: account, password: password, otpCode: otpCode, cancelToken: cancelToken, rememberDevice: rememberDevice);
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
      Util.setStorage("check_ssl", checkSsl ? "1" : "0");
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
          servers[i]['check_ssl'] = checkSsl;
          servers[i]['cookie'] = Util.cookie;
          servers[i]['sid'] = res['data']['sid'];
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
          "check_ssl": checkSsl,
          "cookie": Util.cookie,
          "sid": res['data']['sid'],
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
      } else if (res['error']['code'] == 403) {
        Util.toast("请输入二次验证代码");
        setState(() {
          needOtp = true;
        });
      } else if (res['error']['code'] == 404) {
        _otpController.clear();
        Util.toast("错误的验证代码。请再试一次。");
      } else {
        Util.toast("登录失败，code:${res['error']['code']}");
      }
    }
  }

  Widget _buildServerItem(server) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: NeuButton(
        onPressed: () async {
          Navigator.of(context).pop();
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
            checkSsl = server['check_ssl'] ?? true;
            Util.cookie = server['cookie'];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "账号登录",
        ),
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
                      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                        return Accounts();
                      }));
                      return;
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Material(
                            color: Colors.transparent,
                            child: NeuCard(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.8,
                              bevel: 5,
                              curveType: CurveType.emboss,
                              decoration: NeumorphicDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
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
                                    Expanded(
                                      child: ListView.builder(
                                        padding: EdgeInsets.all(20),
                                        itemBuilder: (context, i) {
                                          return _buildServerItem(servers[i]);
                                        },
                                        itemCount: servers.length,
                                      ),
                                    ),
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
            if (needOtp) ...[
              Row(
                children: [
                  Expanded(
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      bevel: 12,
                      curveType: CurveType.flat,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: NeuTextField(
                        controller: _otpController,
                        onChanged: (v) => otpCode = v,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '二步验证代码',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      setState(() {
                        rememberDevice = !rememberDevice;
                      });
                    },
                    child: NeuCard(
                      decoration: NeumorphicDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      curveType: rememberDevice ? CurveType.emboss : CurveType.flat,
                      bevel: 12,
                      height: 68,
                      width: 120,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        children: [
                          Text("记住设备"),
                          Spacer(),
                          if (rememberDevice)
                            Icon(
                              CupertinoIcons.checkmark_alt,
                              color: Color(0xffff9813),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
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
            if (https)
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      checkSsl = !checkSsl;
                    });
                  },
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    curveType: checkSsl ? CurveType.emboss : CurveType.flat,
                    bevel: 12,
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Text("验证SSL证书"),
                        Spacer(),
                        if (checkSsl)
                          Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xffff9813),
                          ),
                      ],
                    ),
                  ),
                ),
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
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                          radius: 13,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "取消",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
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
