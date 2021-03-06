import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dsm_helper/pages/login/accounts.dart';
import 'package:dsm_helper/pages/setting/license.dart';
import 'package:dsm_helper/pages/update/update.dart';
import 'package:dsm_helper/util/api.dart';
import 'package:dsm_helper/util/function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:neumorphic/neumorphic.dart';
import 'package:package_info/package_info.dart';
import 'package:vibrate/vibrate.dart';

class Login extends StatefulWidget {
  final Map server;
  final String type;
  Login({this.server, this.type: "login"});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TapGestureRecognizer _privacyRecognizer;
  Map updateInfo;
  String host = "";
  String baseUrl = '';
  String account = "";
  String note = "";
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
  bool read = false;
  TextEditingController _hostController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _portController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  List servers = [];
  List qcAddresses = [];
  CancelToken cancelToken = CancelToken();
  @override
  initState() {
    _privacyRecognizer = TapGestureRecognizer();
    checkUpdate();
    Util.getStorage("read").then((value) {
      if (value.isNotBlank && value == "1") {
        setState(() {
          read = true;
        });
      }
    });
    Util.getStorage("servers").then((serverString) {
      if (serverString.isNotBlank) {
        servers = jsonDecode(serverString);
      }
      if (widget.server != null) {
        setState(() {
          https = widget.server['https'];
          host = widget.server['host'];
          port = widget.server['port'];
          account = widget.server['account'];
          note = widget.server['note'] ?? '';
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
          if (note.isNotBlank) {
            _noteController.value = TextEditingValue(text: note);
          }
          if (password.isNotBlank) {
            _passwordController.value = TextEditingValue(text: password);
          }
        });
        Util.cookie = widget.server['cookie'];
        Util.sid = widget.server['sid'];
        if (widget.server['action'] == "login") {
          _login();
        }
      } else {
        if (widget.type == "login") {
          getInfo();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _privacyRecognizer.dispose();
    super.dispose();
  }

  checkUpdate() async {
    if (Platform.isAndroid) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      var res = await Api.update(packageInfo.buildNumber); //packageInfo.buildNumber
      print(res);
      if (res['code'] == 1) {
        setState(() {
          updateInfo = res['data'];
        });
      }
    }
  }

  getInfo() async {
    sid = await Util.getStorage("sid");
    smid = await Util.getStorage("smid");
    String httpsString = await Util.getStorage("https");
    host = await Util.getStorage("host") ?? "";
    baseUrl = await Util.getStorage("base_url");
    String portString = await Util.getStorage("port");
    account = await Util.getStorage("account");
    note = await Util.getStorage("note");
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
    if (portString.isNotBlank) {
      port = portString;
      _portController.value = TextEditingValue(text: portString);
    } else {
      _portController.value = TextEditingValue(text: port);
    }
    if (account.isNotBlank) {
      _accountController.value = TextEditingValue(text: account);
    }
    if (note.isNotBlank) {
      _noteController.value = TextEditingValue(text: note);
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
    checkLogin();
  }

  checkLogin() async {
    if (https != null && sid.isNotBlank && host.isNotBlank) {
      if (baseUrl.isNotBlank) {
        Util.baseUrl = baseUrl;
      } else {
        Util.baseUrl = "${https ? "https" : "http"}://$host:$port";
      }
      //??????????????????
      print("BaseUrl:$baseUrl");
      print("Util.BaseUrl:${Util.baseUrl}");
      Util.sid = sid;
      //?????????????????????????????????????????????????????????
      if (autoLogin) {
        setState(() {
          login = true;
        });
        var checkLogin = await Api.shareList(cancelToken: cancelToken);
        if (!checkLogin['success']) {
          if (checkLogin['code'] == "????????????") {
            //??????????????????????????????
            setState(() {
              login = false;
            });
          } else {
            //???????????????????????????????????????
            print("??????????????????");
            _login();
          }
        } else {
          //???????????????????????????
          Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
        }
      }
    }
  }

  _login() async {
    Util.checkSsl = checkSsl;
    FocusScope.of(context).requestFocus(FocusNode());

    if (host.trim() == "") {
      Util.toast("???????????????/IP/QuickConnect ID");
      return;
    }
    if (account == "") {
      Util.toast("???????????????");
      return;
    }
    setState(() {
      login = true;
    });
    if (host.contains(".")) {
      String baseUri = "${https ? "https" : "http"}://${host.trim()}:${port.trim()}";
      doLogin(baseUri);
    } else {
      qcLogin();
    }
  }

  qcLogin({String qcHost: "global.quickconnect.cn"}) async {
    print("QuickConnectID:$host");
    var res = await Api.quickConnect(host, baseUrl: qcHost);
    print(res);
    if (res['errno'] == 0) {
      if (res['server']['fqdn'] != "NULL") {
        qcAddresses.add("http://${res['server']['fqdn']}/");
      }
      if (res['server']['external']["ip"] != null) {
        qcAddresses.add("http://${res['server']['external']["ip"]}:${res['service']['ext_port']}/");
      }
      if (res['service']['relay_ip'] != null) {
        qcAddresses.add("http://${res['service']['relay_ip']}:${res['service']['relay_port']}/");
      }
      if (res['server']['ddns'] != "NULL") {
        qcAddresses.add("http://${res['server']['ddns']}:${res['service']['ext_port']}/");
      }
      if (res['server']['interface'].length > 0) {
        for (var interface in res['server']['interface']) {
          qcAddresses.add("http://${interface['ip']}:${res['service']['port']}/");
          if (interface['ipv6'].length > 0) {
            for (var v6 in interface['ipv6']) {
              qcAddresses.add("http://[${v6['address']}]:${res['service']['port']}/");
            }
          }
        }
      }
      if (res['service']['relay_ip'] == null) {
        var cnRes = await Api.quickConnectCn(host, baseUrl: res['env']['control_host']);
        if (cnRes['errno'] == 0) {
          if (cnRes['service']['relay_ip'] != null) {
            qcAddresses.add("http://${cnRes['service']['relay_ip']}:${cnRes['service']['relay_port']}/");
          }
        }
      }

      bool finded = false;
      for (var address in qcAddresses) {
        print(qcAddresses);
        Api.pingpong(address, (res) {
          if (res != null) {
            if (!finded) {
              setState(() {
                finded = true;
              });
              doLogin(res);
            }
          }
        });
      }
    } else if (res['errno'] == 4 && res['errinfo'] == "get_server_info.go:105[]" && res['sites'].length > 0) {
      qcLogin(qcHost: res['sites'][0]);
    } else {
      Util.toast("????????????????????????????????????QuickConnect ID????????????");
      setState(() {
        login = false;
      });
    }
  }

  doLogin(String baseUri) async {
    var res = await Api.login(host: baseUri, account: account, password: password, otpCode: otpCode, cancelToken: cancelToken, rememberDevice: rememberDevice);
    setState(() {
      login = false;
    });
    if (res['success'] == true) {
      //??????????????????

      Util.setStorage("https", https ? "1" : "0");
      Util.setStorage("host", host.trim());
      Util.setStorage("port", port);
      Util.setStorage("base_url", baseUri);
      Util.setStorage("account", account);
      Util.setStorage("note", note);
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

      //?????????????????????
      bool exist = false;
      for (int i = 0; i < servers.length; i++) {
        if (servers[i]['https'] == https && servers[i]['host'] == host && servers[i]['port'] == port && servers[i]['account'] == account) {
          print("??????????????????????????????");
          if (rememberPassword) {
            servers[i]['password'] = password;
          } else {
            servers[i]['password'] = "";
          }

          servers[i]['remember_password'] = rememberPassword;
          servers[i]['note'] = note;
          servers[i]['auto_login'] = autoLogin;
          servers[i]['check_ssl'] = checkSsl;
          servers[i]['cookie'] = Util.cookie;
          servers[i]['sid'] = res['data']['sid'];
          servers[i]['base_url'] = baseUri;
          exist = true;
        }
      }
      if (!exist) {
        print("???????????????");
        Map server = {
          "https": https,
          "host": host,
          "base_url": baseUri,
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
      if (widget.type == "login") {
        Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
      } else {
        Navigator.of(context).pop(true);
      }
    } else {
      Util.vibrate(FeedbackType.warning);
      if (res['error']['code'] == 400) {
        Util.toast("?????????/????????????");
      } else if (res['error']['code'] == 403) {
        Util.toast("???????????????????????????");
        setState(() {
          needOtp = true;
        });
      } else if (res['error']['code'] == 404) {
        _otpController.clear();
        Util.toast("??????????????????????????????????????????");
      } else {
        Util.toast("???????????????code:${res['error']['code']}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: updateInfo != null
            ? Padding(
                padding: EdgeInsets.only(left: 10, top: 8, bottom: 8),
                child: NeuButton(
                  decoration: NeumorphicDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(10),
                  bevel: 5,
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                      return Update(updateInfo);
                    }));
                  },
                  child: Image.asset(
                    "assets/icons/update.png",
                    width: 20,
                    height: 20,
                    color: Colors.redAccent,
                  ),
                ),
              )
            : null,
        title: Text(
          widget.type == "login" ? "????????????" : "????????????",
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
                  SizedBox(
                    width: 60,
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
                            "??????",
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
                      onChanged: (v) {
                        setState(() {
                          host = v;
                        });
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '??????/IP/QuickConnect ID',
                      ),
                    ),
                  ),
                  if (host.contains("."))
                    Expanded(
                      flex: 1,
                      child: NeuTextField(
                        onChanged: (v) => port = v,
                        controller: _portController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '??????',
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: NeuTextField(
                      keyboardAppearance: Brightness.light,
                      controller: _accountController,
                      onChanged: (v) => account = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '??????',
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    bevel: 20,
                    curveType: CurveType.flat,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: NeuTextField(
                      keyboardAppearance: Brightness.light,
                      controller: _noteController,
                      onChanged: (v) => note = v,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: '??????',
                      ),
                    ),
                  ),
                ),
              ],
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
                  labelText: '??????',
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
                          labelText: '??????????????????',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
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
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          children: [
                            Text("????????????"),
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
                          Text("????????????"),
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
                          Text("????????????"),
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
                        Text("??????SSL??????"),
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
              onPressed: () {
                if (!read) {
                  Util.toast("????????????????????????????????????????????????");
                  return;
                }
                if (login) {
                  if (login == true) {
                    cancelToken?.cancel("????????????");
                    cancelToken = CancelToken();
                    return;
                  }
                } else {
                  _login();
                }
              },
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
                          "??????",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    )
                  : Text(
                      widget.type == "login" ? ' ?????? ' : ' ?????? ',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  read = !read;
                  Util.setStorage("read", read ? "1" : "0");
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeuCard(
                    decoration: NeumorphicDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    height: 20,
                    width: 20,
                    alignment: Alignment.center,
                    curveType: read ? CurveType.emboss : CurveType.flat,
                    child: read
                        ? Icon(
                            CupertinoIcons.checkmark_alt,
                            color: Color(0xffff9813),
                            size: 14,
                          )
                        : SizedBox(),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: "????????????????????? "),
                        TextSpan(
                          text: "${Util.appName}???????????????????????????",
                          style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue, fontSize: 12),
                          recognizer: _privacyRecognizer
                            ..onTap = () {
                              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                                return License();
                              }));
                            },
                        ),
                      ],
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
