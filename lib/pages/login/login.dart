import 'package:file_station/util/api.dart';
import 'package:file_station/util/function.dart';
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
  bool remember = true;
  bool login = false;
  TextEditingController _portController = TextEditingController();
  @override
  initState() {
    _portController.value = TextEditingValue(text: port);
    super.initState();
  }

  _login() async {
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
    await Future.delayed(Duration(seconds: 2));
    var res = await Api.login(host: baseUri, account: account, password: password);
    setState(() {
      login = false;
    });
    if (res['success'] == true) {
      print(res);
      //记住登录信息

      Util.setStorage("sid", res['data']['sid']);
      Util.setStorage("host", baseUri);
      Util.sid = res['data']['sid'];
      Util.baseUrl = baseUri;
      Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
    } else {
      print(res);
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
      appBar: NeuAppBar(
        title: Text("File Station"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
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
                        onChanged: (v) => host = v,
                        controller: _portController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: '端口',
                        ),
                      ),
                    ),
                  ],
                )),
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
